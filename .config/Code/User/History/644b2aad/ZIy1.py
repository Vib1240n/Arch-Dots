import discord
from discord.ext import commands, tasks
import asyncio
import os
from dotenv import load_dotenv

# Import from parent directory
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from logger import logger
from redis_manager import get_redis_manager
from config import is_bot_owner

load_dotenv()

# Get redis manager instance
redis_manager = get_redis_manager()

def safe_int_env(env_var: str, default: int = 0) -> int:
    """Safely parse integer from environment variable"""
    value = os.getenv(env_var, "")
    if value.strip() == "":
        return default
    try:
        return int(value, 16) if value.startswith("0x") else int(value)
    except ValueError:
        # print(f"[WARNING] Invalid integer for {env_var}: '{value}', using {default}")
        logger.warning(f"Invalid integer for {env_var}: '{value}', using {default}")
        return default

# Configuration from environment variables
MAIN_SERVER_ID = safe_int_env("MAIN_SERVER_ID", 0)
BACKUP_SERVER_ID = safe_int_env("BACKUP_SERVER_ID", 0)
CULT_ROLE_ID = safe_int_env("CULT_ROLE_ID", 0)
JAILED_ROLE_ID = safe_int_env("JAILED_ROLE_ID", 0)
IMUTED_ROLE_ID = safe_int_env("IMUTED_ROLE_ID", 0)
RMUTED_ROLE_ID = safe_int_env("RMUTED_ROLE_ID", 0)

# Excluded roles that prevent cult member role
EXCLUDED_ROLE_IDS = [JAILED_ROLE_ID, IMUTED_ROLE_ID, RMUTED_ROLE_ID]

backup_logs_enabled = True

def toggle_backup_logging():
    """Toggle backup system logging on/off"""
    global backup_logs_enabled
    backup_logs_enabled = not backup_logs_enabled
    # console.print(f"[purple][BACKUP]:[/purple] Logging {'enabled' if backup_logs_enabled else 'disabled'}")
    logger.log('SYNC', f"Logging {'enabled' if backup_logs_enabled else 'disabled'}")

class BackupIntegration(commands.Cog):
    def __init__(self, bot, register_console_command=None):
        self.bot = bot
        if register_console_command:
            register_console_command("lbu", toggle_backup_logging, "Toggle backup logs on/off")
        logger.log('LOADED', 'Backup integration system initialized')

    async def cog_load(self):
        """Called when cog is loaded"""
        # Tasks auto-start via before_loop hooks
        pass

    def cog_unload(self):
        """Clean up when cog is unloaded"""
        self.sweep_members.cancel()

    @tasks.loop(minutes=2)
    async def sweep_members(self):
        """Periodically sync cult member roles between main and backup servers"""
        # Check if cog is active
        if not redis_manager.is_cog_active("backup"):
            return

        # Skip silently if no backup server configured
        if not BACKUP_SERVER_ID:
            return

        main_server = self.bot.get_guild(MAIN_SERVER_ID)
        backup_server = self.bot.get_guild(BACKUP_SERVER_ID)

        if not main_server or not backup_server:
            if backup_logs_enabled:
                # console.print("[red][BACKUP]:[/red] Main or backup server not found")
                logger.error("Main or backup server not found")
            return

        cult_role = main_server.get_role(CULT_ROLE_ID)
        if not cult_role:
            if backup_logs_enabled:
                # console.print("[red][BACKUP]:[/red] Cult role not found")
                logger.error("Cult role not found")
            return

        # Get excluded roles
        excluded_roles = [main_server.get_role(rid) for rid in EXCLUDED_ROLE_IDS if rid]
        excluded_roles = [r for r in excluded_roles if r is not None]

        # Process members in batches
        members = main_server.members
        batch_size = 500

        for i in range(0, len(members), batch_size):
            batch = members[i:i + batch_size]

            for member in batch:
                # Skip bots
                if member.bot:
                    continue

                # Check if member has any excluded roles
                has_excluded = any(role in member.roles for role in excluded_roles)
                has_cult_role = cult_role in member.roles
                is_in_backup = backup_server.get_member(member.id) is not None

                # If member has excluded role, remove cult role if they have it
                if has_excluded:
                    if has_cult_role:
                        try:
                            await member.remove_roles(cult_role, reason="Has excluded role (jailed/muted)")
                            if backup_logs_enabled:
                                # console.print(f"[blue][BACKUP]:[/blue] Removed cult role from {member} (excluded)")
                                logger.log('SYNC', f"Removed cult role from {member} (excluded)")
                        except discord.Forbidden:
                            if backup_logs_enabled:
                                # console.print(f"[red][BACKUP]:[/red] No permission to remove role from {member}")
                                logger.error(f"No permission to remove role from {member}")
                        except Exception as e:
                            if backup_logs_enabled:
                                # console.print(f"[red][BACKUP]:[/red] Error removing role: {e}")
                                logger.error(f"Error removing role: {e}")
                    continue

                # Sync cult role based on backup server membership
                if is_in_backup and not has_cult_role:
                    try:
                        await member.add_roles(cult_role, reason="Member in backup server")
                        if backup_logs_enabled:
                            # console.print(f"[green][BACKUP]:[/green] Added cult role to {member}")
                            logger.log('SYNC', f"Added cult role to {member}")
                    except discord.Forbidden:
                        if backup_logs_enabled:
                            # console.print(f"[red][BACKUP]:[/red] No permission to add role to {member}")
                            logger.error(f"No permission to add role to {member}")
                    except Exception as e:
                        if backup_logs_enabled:
                            # console.print(f"[red][BACKUP]:[/red] Error adding role: {e}")
                            logger.error(f"Error adding role: {e}")

                elif not is_in_backup and has_cult_role:
                    try:
                        await member.remove_roles(cult_role, reason="Not in backup server")
                        if backup_logs_enabled:
                            # console.print(f"[yellow][BACKUP]:[/yellow] Removed cult role from {member}")
                            logger.log('SYNC', f"Removed cult role from {member}")
                    except discord.Forbidden:
                        if backup_logs_enabled:
                            # console.print(f"[red][BACKUP]:[/red] No permission to remove role from {member}")
                            logger.error(f"No permission to remove role from {member}")
                    except Exception as e:
                        if backup_logs_enabled:
                            # console.print(f"[red][BACKUP]:[/red] Error removing role: {e}")
                            logger.error(f"Error removing role: {e}")

            # Small delay between batches to avoid rate limits
            await asyncio.sleep(1)

        if backup_logs_enabled:
            # console.print("[blue][BACKUP]:[/blue] Member sweep completed")
            logger.log('SYNC', "Member sweep completed")

    @commands.Cog.listener()
    async def on_member_join(self, member: discord.Member):
        """Handle when a member joins the backup server"""
        # Check if cog is active
        if not redis_manager.is_cog_active("backup"):
            return

        # Skip if no backup server configured
        if not BACKUP_SERVER_ID:
            return

        # Only process if member joined backup server
        if member.guild.id != BACKUP_SERVER_ID:
            return

        # Skip bots
        if member.bot:
            return

        main_server = self.bot.get_guild(MAIN_SERVER_ID)
        if not main_server:
            return

        main_member = main_server.get_member(member.id)
        if not main_member:
            return

        cult_role = main_server.get_role(CULT_ROLE_ID)
        if not cult_role:
            return

        # Check for excluded roles
        excluded_roles = [main_server.get_role(rid) for rid in EXCLUDED_ROLE_IDS if rid]
        excluded_roles = [r for r in excluded_roles if r is not None]

        if any(role in main_member.roles for role in excluded_roles):
            if backup_logs_enabled:
                # console.print(f"[yellow][BACKUP]:[/yellow] {member} has excluded role, not adding cult role")
                logger.log('SYNC', f"{member} has excluded role, not adding cult role")
            return

        # Add cult role if they don't have it
        if cult_role not in main_member.roles:
            try:
                await main_member.add_roles(cult_role, reason="Joined backup server")
                if backup_logs_enabled:
                    # console.print(f"[green][BACKUP]:[/green] Added cult role to {main_member} (joined backup)")
                    logger.log('SYNC', f"Added cult role to {main_member} (joined backup)")
            except discord.Forbidden:
                if backup_logs_enabled:
                    # console.print(f"[red][BACKUP]:[/red] No permission to add role to {main_member}")
                    logger.error(f"No permission to add role to {main_member}")
            except Exception as e:
                if backup_logs_enabled:
                    # console.print(f"[red][BACKUP]:[/red] Error adding role: {e}")
                    logger.error(f"Error adding role: {e}")

    @commands.Cog.listener()
    async def on_member_remove(self, member: discord.Member):
        """Handle when a member leaves the backup server"""
        # Check if cog is active
        if not redis_manager.is_cog_active("backup"):
            return

        # Skip if no backup server configured
        if not BACKUP_SERVER_ID:
            return

        # Only process if member left backup server
        if member.guild.id != BACKUP_SERVER_ID:
            return

        # Skip bots
        if member.bot:
            return

        main_server = self.bot.get_guild(MAIN_SERVER_ID)
        if not main_server:
            return

        main_member = main_server.get_member(member.id)
        if not main_member:
            return

        cult_role = main_server.get_role(CULT_ROLE_ID)
        if not cult_role:
            return

        # Remove cult role if they have it
        if cult_role in main_member.roles:
            try:
                await main_member.remove_roles(cult_role, reason="Left backup server")
                if backup_logs_enabled:
                    # console.print(f"[yellow][BACKUP]:[/yellow] Removed cult role from {main_member} (left backup)")
                    logger.log('SYNC', f"Removed cult role from {main_member} (left backup)")
            except discord.Forbidden:
                if backup_logs_enabled:
                    # console.print(f"[red][BACKUP]:[/red] No permission to remove role from {main_member}")
                    logger.error(f"No permission to remove role from {main_member}")
            except Exception as e:
                if backup_logs_enabled:
                    # console.print(f"[red][BACKUP]:[/red] Error removing role: {e}")
                    logger.error(f"Error removing role: {e}")

    @sweep_members.before_loop
    async def before_sweep_members(self):
        """Wait for bot to be ready before starting the sweep loop"""
        await self.bot.wait_until_ready()
        # Run initial sweep
        await self.sweep_members()

    @commands.command(name="syncbackup")
    async def force_sync(self, ctx):
        """Manually trigger a backup server member sync (admin only)"""
        # Check if user is bot owner
        if not is_bot_owner(ctx.author.id):
            return await ctx.send("❌ Only bot owners can use this command.", delete_after=5)

        if not redis_manager.is_cog_active("backup"):
            return await ctx.send("⏸️ **backup** is currently paused.", delete_after=5)

        await ctx.send("🔄 Starting manual sync...")
        await self.sweep_members()
        await ctx.send("✅ Manual sync completed")

async def setup(bot):
    await bot.add_cog(BackupIntegration(bot))

