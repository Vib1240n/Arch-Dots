import discord
from discord.ext import commands
from datetime import datetime
import os
from dotenv import load_dotenv

# Import from parent directory
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from logger import logger
from redis_manager import get_redis_manager
from config import is_bot_owner
from config_manager import get_channel_id, is_authorized, get_user_auth_level
from cogs.frontend._embed_styles import occult_embed

load_dotenv()

COG_VERSION = "2.0.0"
LAST_UPDATE = "2025-11-12 - Added command logging system"


def safe_int_env(env_var: str, default: int = 0) -> int:
    """Safely parse integer from environment variable"""
    value = os.getenv(env_var, "")
    if value.strip() == "":
        return default
    try:
        return int(value, 16) if value.startswith("0x") else int(value)
    except ValueError:
        logger.warning(f"Invalid integer for {env_var}: '{value}', using {default}")
        return default


# Configuration from environment variables
SERVER_LOG_CHANNEL_ID = safe_int_env("SERVER_LOG_CHANNEL_ID", 0)
EMBED_COLOR = safe_int_env("EMBED_COLOR", 0x28242C)

# Role IDs for context
ARCHON_ROLE_ID = safe_int_env("ARCHON_ROLE_ID", 0)
ARCANIST_ROLE_ID = safe_int_env("ARCANIST_ROLE_ID", 0)
WARDEN_ROLE_ID = safe_int_env("WARDEN_ROLE_ID", 0)
JAILED_ROLE_ID = safe_int_env("JAILED_ROLE_ID", 0)
IMUTED_ROLE_ID = safe_int_env("IMUTED_ROLE_ID", 0)
RMUTED_ROLE_ID = safe_int_env("RMUTED_ROLE_ID", 0)
FOLLOWER_ROLE_ID = safe_int_env("FOLLOWER_ROLE_ID", 0)
CULT_ROLE_ID = safe_int_env("CULT_ROLE_ID", 0)


class ServerLogs(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.redis = get_redis_manager()
        self.tracked_role_ids = {
            JAILED_ROLE_ID,
            IMUTED_ROLE_ID,
            RMUTED_ROLE_ID,
            FOLLOWER_ROLE_ID,
            CULT_ROLE_ID,
            ARCHON_ROLE_ID,
            ARCANIST_ROLE_ID,
            WARDEN_ROLE_ID,
        }
        logger.log("LOADED", f"Server logging system initialized (v{COG_VERSION})")

    async def send_log(self, embed: discord.Embed, guild: discord.Guild):
        """Send a log embed to the server logs channel"""
        log_channel = self.bot.get_channel(SERVER_LOG_CHANNEL_ID)
        if not log_channel:
            logger.error(f"Log channel not found (ID: {SERVER_LOG_CHANNEL_ID})")
            return

        try:
            await log_channel.send(embed=embed)
        except Exception as e:
            logger.error(f"Failed to send log: {e}")

    async def send_command_log(self, embed: discord.Embed, guild: discord.Guild):
        """Send a command log embed to the command-log channel (or fallback to log channel)"""
        if not self.redis or not self.redis.client:
            logger.error("Redis not available for command logging")
            return

        try:
            # Get command-log channel from Redis
            command_log_id = await get_channel_id(
                self.redis, guild.id, "command-log", default=0
            )

            # Fallback to regular log channel if command-log not set
            if not command_log_id:
                command_log_id = await get_channel_id(
                    self.redis, guild.id, "log", default=0
                )

            # Final fallback to env variable
            if not command_log_id:
                command_log_id = SERVER_LOG_CHANNEL_ID

            log_channel = self.bot.get_channel(command_log_id)
            if not log_channel:
                logger.error(f"Command log channel not found (ID: {command_log_id})")
                return

            await log_channel.send(embed=embed)
        except Exception as e:
            logger.error(f"Failed to send command log: {e}")

    def get_role_name(self, role_id: int) -> str:
        """Get a readable name for role IDs"""
        role_map = {
            JAILED_ROLE_ID: "Jailed",
            IMUTED_ROLE_ID: "iMuted",
            RMUTED_ROLE_ID: "rMuted",
            FOLLOWER_ROLE_ID: "Follower",
            CULT_ROLE_ID: "Cult",
            ARCHON_ROLE_ID: "Archon",
            ARCANIST_ROLE_ID: "Arcanist",
            WARDEN_ROLE_ID: "Warden",
        }
        return role_map.get(role_id, "Unknown Role")

    @commands.Cog.listener()
    async def on_command_completion(self, ctx: commands.Context):
        """Log when commands are executed by staff/mods"""
        if not self.redis:
            return

        # Skip if not in a guild
        if not ctx.guild:
            return

        # Skip if command executed in bot-dev channel
        bot_dev_id = await get_channel_id(
            self.redis, ctx.guild.id, "bot-dev", default=0
        )
        if bot_dev_id and ctx.channel.id == bot_dev_id:
            return

        # Only log commands from authorized users (moderator level and above)
        try:
            if not await is_authorized(
                self.redis, ctx.author, ctx.guild.id, "moderator"
            ):
                return
        except:
            # If authorization check fails, skip logging
            return

        # Get user's auth level for display
        try:
            auth_level = await get_user_auth_level(self.redis, ctx.author, ctx.guild.id)
        except:
            auth_level = "unknown"

        # Get command name and args
        command_name = ctx.command.qualified_name if ctx.command else "unknown"

        # Build command string with args
        command_args = ""
        if ctx.args[2:]:  # Skip self and ctx
            command_args = " ".join(str(arg) for arg in ctx.args[2:])
        if ctx.kwargs:
            command_args += " " + " ".join(f"{k}={v}" for k, v in ctx.kwargs.items())

        full_command = f"{ctx.prefix}{command_name}"
        if command_args:
            full_command += f" {command_args}"

        # Format timestamp
        timestamp_str = datetime.utcnow().strftime("%H:%M:%S UTC")

        # Create occult-style embed
        description = (
            f"𐄞𐄞 𐄙 command executed 𐄙 𐄞𐄞\n\n"
            f"𓂃 command: `{full_command}`\n"
            f"𓂃 by: {ctx.author.mention} ({auth_level})\n"
            f"𓂃 in: {ctx.channel.mention}\n"
            f"𓂃 at: {timestamp_str}"
        )

        embed = occult_embed(description=description, color="info", timestamp=True)

        # Send to command log channel
        await self.send_command_log(embed, ctx.guild)

        # Also log to file
        logger.log(
            "COMMAND",
            f"{ctx.author} ({auth_level}) used {full_command} in #{ctx.channel.name}",
        )

    @commands.Cog.listener()
    async def on_member_join(self, member: discord.Member):
        """Log when members join the server"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        embed = discord.Embed(
            title="✅ Member Joined", color=0x00FF00, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Member", value=f"{member.mention}", inline=True)
        embed.add_field(name="ID", value=f"`{member.id}`", inline=True)
        embed.add_field(
            name="Account Created",
            value=discord.utils.format_dt(member.created_at, "R"),
            inline=False,
        )
        embed.set_thumbnail(url=member.display_avatar.url)

        await self.send_log(embed, member.guild)

    @commands.Cog.listener()
    async def on_member_remove(self, member: discord.Member):
        """Log when members leave the server"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        embed = discord.Embed(
            title="❌ Member Left", color=0xFF0000, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Member", value=f"{member.mention}", inline=True)
        embed.add_field(name="ID", value=f"`{member.id}`", inline=True)

        # Show roles they had
        roles = [
            r.mention for r in member.roles if r.id != member.guild.default_role.id
        ]
        if roles:
            roles_text = ", ".join(roles[:10])  # Limit to 10 roles
            if len(roles) > 10:
                roles_text += f" (+{len(roles)-10} more)"
            embed.add_field(name="Roles", value=roles_text, inline=False)

        embed.set_thumbnail(url=member.display_avatar.url)

        await self.send_log(embed, member.guild)

    @commands.Cog.listener()
    async def on_member_ban(self, guild: discord.Guild, user: discord.User):
        """Log when members are banned"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Try to get ban reason from audit log
        reason = "No reason provided"
        banned_by = "Unknown"

        try:
            async for entry in guild.audit_logs(
                limit=5, action=discord.AuditLogAction.ban
            ):
                if entry.target.id == user.id:
                    reason = entry.reason or "No reason provided"
                    banned_by = entry.user.mention
                    break
        except:
            pass

        embed = discord.Embed(
            title="🔨 Member Banned", color=0xFF0000, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Member", value=f"{user.mention}", inline=True)
        embed.add_field(name="ID", value=f"`{user.id}`", inline=True)
        embed.add_field(name="Banned By", value=banned_by, inline=True)
        embed.add_field(name="Reason", value=reason, inline=False)
        embed.set_thumbnail(url=user.display_avatar.url)

        await self.send_log(embed, guild)

    @commands.Cog.listener()
    async def on_member_unban(self, guild: discord.Guild, user: discord.User):
        """Log when members are unbanned"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Try to get unban info from audit log
        unbanned_by = "Unknown"

        try:
            async for entry in guild.audit_logs(
                limit=5, action=discord.AuditLogAction.unban
            ):
                if entry.target.id == user.id:
                    unbanned_by = entry.user.mention
                    break
        except:
            pass

        embed = discord.Embed(
            title="✅ Member Unbanned", color=0x00FF00, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Member", value=f"{user.mention}", inline=True)
        embed.add_field(name="ID", value=f"`{user.id}`", inline=True)
        embed.add_field(name="Unbanned By", value=unbanned_by, inline=True)
        embed.set_thumbnail(url=user.display_avatar.url)

        await self.send_log(embed, guild)

    @commands.Cog.listener()
    async def on_member_update(self, before: discord.Member, after: discord.Member):
        """Log important role changes"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Check if any tracked roles were added or removed
        before_role_ids = {r.id for r in before.roles}
        after_role_ids = {r.id for r in after.roles}

        # Find added tracked roles
        added_tracked = (after_role_ids & self.tracked_role_ids) - (
            before_role_ids & self.tracked_role_ids
        )

        # Find removed tracked roles
        removed_tracked = (before_role_ids & self.tracked_role_ids) - (
            after_role_ids & self.tracked_role_ids
        )

        # Log role additions
        for role_id in added_tracked:
            role = after.guild.get_role(role_id)
            if not role:
                continue

            # Try to get who added the role
            moderator = "System"
            try:
                async for entry in after.guild.audit_logs(
                    limit=5, action=discord.AuditLogAction.member_role_update
                ):
                    if (
                        entry.target.id == after.id
                        and role in entry.after.roles
                        and role not in entry.before.roles
                    ):
                        moderator = entry.user.mention
                        break
            except:
                pass

            embed = discord.Embed(
                title="➕ Role Added", color=0x00FF00, timestamp=discord.utils.utcnow()
            )
            embed.add_field(name="Member", value=f"{after.mention}", inline=True)
            embed.add_field(name="Role", value=f"{role.mention}", inline=True)
            embed.add_field(name="Added By", value=moderator, inline=True)

            await self.send_log(embed, after.guild)

        # Log role removals
        for role_id in removed_tracked:
            role = before.guild.get_role(role_id)
            if not role:
                continue

            # Try to get who removed the role
            moderator = "System"
            try:
                async for entry in after.guild.audit_logs(
                    limit=5, action=discord.AuditLogAction.member_role_update
                ):
                    if (
                        entry.target.id == after.id
                        and role in entry.before.roles
                        and role not in entry.after.roles
                    ):
                        moderator = entry.user.mention
                        break
            except:
                pass

            embed = discord.Embed(
                title="➖ Role Removed",
                color=0xFF6B6B,
                timestamp=discord.utils.utcnow(),
            )
            embed.add_field(name="Member", value=f"{after.mention}", inline=True)
            embed.add_field(name="Role", value=f"{role.mention}", inline=True)
            embed.add_field(name="Removed By", value=moderator, inline=True)

            await self.send_log(embed, after.guild)

        # Log nickname changes
        if before.nick != after.nick:
            embed = discord.Embed(
                title="📝 Nickname Changed",
                color=EMBED_COLOR,
                timestamp=discord.utils.utcnow(),
            )
            embed.add_field(name="Member", value=f"{after.mention}", inline=False)
            embed.add_field(
                name="Before", value=before.nick or before.name, inline=True
            )
            embed.add_field(name="After", value=after.nick or after.name, inline=True)

            await self.send_log(embed, after.guild)

    @commands.Cog.listener()
    async def on_guild_channel_create(self, channel):
        """Log when channels are created"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Get who created it
        creator = "Unknown"
        try:
            async for entry in channel.guild.audit_logs(
                limit=5, action=discord.AuditLogAction.channel_create
            ):
                if entry.target.id == channel.id:
                    creator = entry.user.mention
                    break
        except:
            pass

        embed = discord.Embed(
            title="✅ Channel Created", color=0x00FF00, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Channel", value=f"{channel.mention}", inline=True)
        embed.add_field(name="Type", value=str(channel.type).title(), inline=True)
        embed.add_field(name="Created By", value=creator, inline=True)

        await self.send_log(embed, channel.guild)

    @commands.Cog.listener()
    async def on_guild_channel_delete(self, channel):
        """Log when channels are deleted"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Get who deleted it
        deleter = "Unknown"
        try:
            async for entry in channel.guild.audit_logs(
                limit=5, action=discord.AuditLogAction.channel_delete
            ):
                if entry.target.id == channel.id:
                    deleter = entry.user.mention
                    break
        except:
            pass

        embed = discord.Embed(
            title="❌ Channel Deleted", color=0xFF0000, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Channel", value=f"#{channel.name}", inline=True)
        embed.add_field(name="Type", value=str(channel.type).title(), inline=True)
        embed.add_field(name="Deleted By", value=deleter, inline=True)

        await self.send_log(embed, channel.guild)

    @commands.Cog.listener()
    async def on_guild_role_create(self, role: discord.Role):
        """Log when roles are created"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Get who created it
        creator = "Unknown"
        try:
            async for entry in role.guild.audit_logs(
                limit=5, action=discord.AuditLogAction.role_create
            ):
                if entry.target.id == role.id:
                    creator = entry.user.mention
                    break
        except:
            pass

        embed = discord.Embed(
            title="✅ Role Created", color=0x00FF00, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Role", value=f"{role.mention}", inline=True)
        embed.add_field(name="Created By", value=creator, inline=True)

        await self.send_log(embed, role.guild)

    @commands.Cog.listener()
    async def on_guild_role_delete(self, role: discord.Role):
        """Log when roles are deleted"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Get who deleted it
        deleter = "Unknown"
        try:
            async for entry in role.guild.audit_logs(
                limit=5, action=discord.AuditLogAction.role_delete
            ):
                if entry.target.id == role.id:
                    deleter = entry.user.mention
                    break
        except:
            pass

        embed = discord.Embed(
            title="❌ Role Deleted", color=0xFF0000, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Role", value=f"@{role.name}", inline=True)
        embed.add_field(name="Deleted By", value=deleter, inline=True)

        await self.send_log(embed, role.guild)

    @commands.Cog.listener()
    async def on_message_delete(self, message: discord.Message):
        """Log when messages are deleted (only in specific channels if needed)"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        # Skip bot messages and DMs
        if message.author.bot or not message.guild:
            return

        # Optional: Only log deletions in certain channels
        # if message.channel.id not in MONITORED_CHANNEL_IDS:
        #     return

        embed = discord.Embed(
            title="🗑️ Message Deleted", color=0xFF6B6B, timestamp=discord.utils.utcnow()
        )
        embed.add_field(name="Author", value=f"{message.author.mention}", inline=True)
        embed.add_field(name="Channel", value=f"{message.channel.mention}", inline=True)

        # Show message content (limit to 1024 chars)
        content = message.content[:1000] if message.content else "*No text content*"
        if len(message.content) > 1000:
            content += "... (truncated)"
        embed.add_field(name="Content", value=content, inline=False)

        # Show attachments if any
        if message.attachments:
            attachments_text = "\n".join(
                [f"[{att.filename}]({att.url})" for att in message.attachments[:5]]
            )
            embed.add_field(name="Attachments", value=attachments_text, inline=False)

        await self.send_log(embed, message.guild)

    @commands.Cog.listener()
    async def on_bulk_message_delete(self, messages):
        """Log when messages are bulk deleted"""
        if not self.redis or not self.redis.is_cog_active("logs"):
            return

        if not messages:
            return

        channel = messages[0].channel

        embed = discord.Embed(
            title="🗑️ Bulk Message Delete",
            color=0xFF0000,
            timestamp=discord.utils.utcnow(),
        )
        embed.add_field(name="Channel", value=f"{channel.mention}", inline=True)
        embed.add_field(name="Count", value=f"{len(messages)} messages", inline=True)

        # Try to get who deleted them
        try:
            async for entry in channel.guild.audit_logs(
                limit=5, action=discord.AuditLogAction.message_bulk_delete
            ):
                if entry.extra.channel.id == channel.id:
                    embed.add_field(
                        name="Deleted By", value=entry.user.mention, inline=True
                    )
                    break
        except:
            pass

        await self.send_log(embed, channel.guild)

    @commands.command(name="testlog")
    async def test_log(self, ctx):
        """Test the logging system (admin only)"""
        if not is_bot_owner(ctx.author.id):
            return await ctx.send(
                "❌ Only bot owners can use this command.", delete_after=5
            )

        if not self.redis or not self.redis.is_cog_active("logs"):
            return await ctx.send("⏸️ **logs** is currently paused.", delete_after=5)

        embed = discord.Embed(
            title="🧪 Test Log",
            description="This is a test log message",
            color=EMBED_COLOR,
            timestamp=discord.utils.utcnow(),
        )
        embed.add_field(name="Triggered By", value=ctx.author.mention, inline=True)

        await self.send_log(embed, ctx.guild)
        await ctx.send("✅ Test log sent!")


async def setup(bot):
    await bot.add_cog(ServerLogs(bot))
