from cult import *

COG_VERSION = "3.0.0"
LAST_UPDATE = (
    "2025-11-07 - Modernized with cult library, config_manager, hybrid commands"
)


class Nickname(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.redis = redis_manager
        self._initial_check_done = False
        logger.log("LOADED", f"Nickname system initialized (v{COG_VERSION})")
        logger.log("LOADED", LAST_UPDATE)

    async def cog_load(self):
        """Called when cog is loaded"""
        logger.log("LOADED", f"Nickname cog loaded successfully (v{COG_VERSION})")

    async def cog_unload(self):
        """Called when cog is unloaded"""
        logger.log("LOADED", "Nickname cog unloaded")

    @commands.Cog.listener()
    async def on_ready(self):
        """Check all members for guild tags on bot ready"""
        if self._initial_check_done:
            return

        if not redis_manager.is_cog_active_guild(ctx.guild.id, "nickname"):
            logger.log("NICKNAME", "Cog is paused, skipping initial check")
            return

        self._initial_check_done = True
        logger.log("NICKNAME", "Starting initial guild tag check...")
        await self.check_all_guild_tags()

    async def check_all_guild_tags(self):
        """Check all members and assign taggot role if they have guild avatar/profile"""
        guild = self.bot.guilds[0] if self.bot.guilds else None
        if not guild:
            logger.error("Could not find guild")
            return

        taggot_role_id = await get_role_id(self.redis, guild.id, "taggot")
        taggot_role = guild.get_role(taggot_role_id)

        if not taggot_role:
            logger.error(f"Could not find taggot role")
            return

        logger.log(
            "NICKNAME", f"Checking guild avatars for {len(guild.members)} members..."
        )
        assigned_count = 0

        for member in guild.members:
            if member.bot:
                continue

            # Check if member has a custom GUILD AVATAR (guild profile picture)
            if member.guild_avatar is not None:
                # Member has guild avatar, check if they need taggot role
                if taggot_role not in member.roles:
                    try:
                        await member.add_roles(
                            taggot_role,
                            reason="Has guild avatar - auto-assigned taggot role",
                        )
                        assigned_count += 1
                        logger.log(
                            "NICKNAME",
                            f"Assigned taggot to {member} (has guild avatar)",
                        )
                    except Exception as e:
                        logger.error(f"Failed to assign taggot to {member}: {e}")

        logger.log(
            "NICKNAME",
            f"Initial check complete. Assigned taggot to {assigned_count} members with guild avatars.",
        )

    @commands.Cog.listener()
    async def on_member_update(self, before: discord.Member, after: discord.Member):
        """Check if member added/removed guild tag"""
        if not redis_manager.is_cog_active_guild(after.guild.id, "nickname"):
            return

        taggot_role_id = await get_role_id(self.redis, after.guild.id, "taggot")
        taggot_role = after.guild.get_role(taggot_role_id)

        if not taggot_role:
            return

        # Check if guild avatar changed (indicates guild tag status change)
        if before.guild_avatar != after.guild_avatar:
            if after.guild_avatar and taggot_role not in after.roles:
                # Member added guild tag, give taggot
                try:
                    await after.add_roles(
                        taggot_role,
                        reason="Added guild tag - auto-assigned taggot role",
                    )
                    logger.log(
                        "NICKNAME", f"Auto-assigned taggot to {after} (added guild tag)"
                    )
                except Exception as e:
                    logger.error(f"Failed to assign taggot to {after}: {e}")

    async def get_permission_level(self, member: discord.Member) -> str:
        """Get member's permission level for renaming"""
        auth_level = await get_user_auth_level(self.redis, member, member.guild.id)

        # Map auth levels to permission levels
        if auth_level in ["server_owner", "bot_owner", "owner", "staff"]:
            return "admin"

        # Check for forced taggot
        forced_taggot_id = await get_role_id(
            self.redis, member.guild.id, "forced-taggot"
        )
        if forced_taggot_id and forced_taggot_id in [r.id for r in member.roles]:
            return "forced taggot"

        # Check for taggot
        taggot_id = await get_role_id(self.redis, member.guild.id, "taggot")
        if taggot_id and taggot_id in [r.id for r in member.roles]:
            return "taggot"

        return "none"

    async def can_rename(
        self, executor: discord.Member, target: discord.Member
    ) -> tuple[bool, str]:
        """
        Check if executor can rename target based on permission hierarchy:
        - Admins (Staff+) can rename anyone including themselves
        - Forced Taggot can rename everyone except admins, forced taggots, and themselves
        - Taggot can rename themselves and everyone except admins and forced taggot
        """
        executor_level = await self.get_permission_level(executor)
        target_level = await self.get_permission_level(target)

        # No permission at all
        if executor_level == "none":
            return (
                False,
                "you don't have permission to use this command. you need at least the taggot role.",
            )

        # Admins can rename anyone
        if executor_level == "admin":
            return True, ""

        # Forced taggot can rename everyone except admins, other forced taggots, and themselves
        if executor_level == "forced taggot":
            if target_level == "admin":
                return False, f"you cannot rename {target.mention} (admin role)"
            if target_level == "forced taggot":
                return False, f"you cannot rename {target.mention} (forced taggot)"
            if executor.id == target.id:
                return False, "you cannot rename yourself (forced taggot)"
            return True, ""

        # Taggot can rename themselves and everyone except admins and forced taggot
        if executor_level == "taggot":
            if target_level == "admin":
                return False, f"you cannot rename {target.mention} (admin role)"
            if target_level == "forced taggot":
                return (
                    False,
                    f"you cannot rename {target.mention} (forced taggot role)",
                )
            # Can rename themselves or others with taggot or lower
            return True, ""

        return False, "unknown permission error"

    @commands.hybrid_command(
        name="forcerename",
        description="Force rename a member and assign forced taggot role",
    )
    @app_commands.describe(
        member="The member to force rename",
        nickname="The new nickname",
    )
    async def forcerename(
        self,
        ctx: commands.Context,
        member: discord.Member,
        *,
        nickname: str,
    ):
        """Force rename a member and assign forced taggot role (Staff+ only)"""
        if not redis_manager.is_cog_active_guild(ctx.guild.id, "nickname"):
            desc = "𐄞𐄞 𐄙 nickname paused 𐄙 𐄞𐄞꒱\n\n𓂃 cog is inactive"
            embed = occult_embed(description=desc, color="error")
            return await ctx.send(embed=embed, ephemeral=True)

        await ctx.defer(ephemeral=True)

        try:
            # Staff+ required
            if not await is_authorized(self.redis, ctx.author, ctx.guild.id, "staff"):
                desc = "𐄞𐄞 𐄙 access denied 𐄙 𐄞𐄞꒱\n\n𓂃 staff+ permission required"
                embed = occult_embed(description=desc, color="error")
                return await ctx.send(embed=embed, ephemeral=True)

            # Cannot force rename other admins
            target_auth_level = await get_user_auth_level(
                self.redis, member, ctx.guild.id
            )
            if target_auth_level in ["server_owner", "bot_owner", "owner", "staff"]:
                desc = f"𐄞𐄞 𐄙 cannot rename admin 𐄙 𐄞𐄞꒱\n\n𓂃 cannot force rename {member.mention} (admin)"
                embed = occult_embed(description=desc, color="error")
                return await ctx.send(embed=embed, ephemeral=True)

            # Check if bot has permission
            if member.top_role >= ctx.guild.me.top_role:
                desc = f"𐄞𐄞 𐄙 role too high 𐄙 𐄞𐄞꒱\n\n𓂃 i cannot change {member.mention}'s nickname (role too high)"
                embed = occult_embed(description=desc, color="error")
                return await ctx.send(embed=embed, ephemeral=True)

            old_nick = member.nick or member.name

            # Get roles
            taggot_role_id = await get_role_id(self.redis, ctx.guild.id, "taggot")
            forced_taggot_role_id = await get_role_id(
                self.redis, ctx.guild.id, "forced-taggot"
            )

            taggot_role = ctx.guild.get_role(taggot_role_id)
            forced_taggot_role = ctx.guild.get_role(forced_taggot_role_id)

            if not forced_taggot_role:
                desc = (
                    "𐄞𐄞 𐄙 not configured 𐄙 𐄞𐄞꒱\n\n𓂃 forced taggot role not configured"
                )
                embed = occult_embed(description=desc, color="error")
                return await ctx.send(embed=embed, ephemeral=True)

            # Change nickname
            await member.edit(
                nick=nickname, reason=f"Force renamed by {ctx.author.name}"
            )

            # Add forced taggot role (keep taggot if they have it)
            roles_to_add = [forced_taggot_role]
            if taggot_role and taggot_role not in member.roles:
                roles_to_add.append(taggot_role)

            await member.add_roles(
                *roles_to_add, reason=f"Force renamed by {ctx.author.name}"
            )

            desc = f"𐄞𐄞 𐄙 force renamed 𐄙 𐄞𐄞꒱\n\n"
            desc += f"𓂃 member: {member.mention}\n"
            desc += f"𓂃 old: `{old_nick}`\n"
            desc += f"𓂃 new: `{nickname}`"

            embed = occult_embed(description=desc, color="success")
            await ctx.send(embed=embed, ephemeral=True)

            logger.log(
                "NICKNAME",
                f"{ctx.author.name} force renamed {member.name} from '{old_nick}' to '{nickname}' and assigned forced taggot",
            )

            # Log to channel if configured
            log_ch_id = await get_channel_id(self.redis, ctx.guild.id, "log")
            log_ch = self.bot.get_channel(log_ch_id)

            if log_ch:
                log_desc = f"𐄞𐄞 𐄙 force rename 𐄙 𐄞𐄞꒱\n\n"
                log_desc += f"𓂃 member: {member.mention}\n"
                log_desc += f"𓂃 by: {ctx.author.mention}\n"
                log_desc += f"𓂃 old: `{old_nick}`\n"
                log_desc += f"𓂃 new: `{nickname}`\n"
                log_desc += "𓂃 forced taggot assigned"

                log_embed = occult_embed(description=log_desc, color="warning")
                await log_ch.send(embed=log_embed)

        except discord.Forbidden:
            desc = f"𐄞𐄞 𐄙 permission error 𐄙 𐄞𐄞꒱\n\n𓂃 i do not have permission to modify {member.mention}"
            embed = occult_embed(description=desc, color="error")
            await ctx.send(embed=embed, ephemeral=True)
            logger.error(f"Missing permissions to force rename {member.name}")
        except Exception as e:
            desc = f"𐄞𐄞 𐄙 error 𐄙 𐄞𐄞꒱\n\n𓂃 {str(e)}"
            embed = occult_embed(description=desc, color="error")
            await ctx.send(embed=embed, ephemeral=True)
            logger.error(f"Failed to force rename: {e}")

    @commands.hybrid_command(name="rename", description="Change a member's nickname")
    @app_commands.describe(
        member="The member whose nickname you want to change",
        nickname="The new nickname (leave empty to reset)",
    )
    async def rename(
        self,
        ctx: commands.Context,
        member: discord.Member,
        *,
        nickname: str = None,
    ):
        """Change a member's nickname if you have the required permissions"""
        if not redis_manager.is_cog_active_guild(ctx.guild.id, "nickname"):
            desc = "𐄞𐄞 𐄙 nickname paused 𐄙 𐄞𐄞꒱\n\n𓂃 cog is inactive"
            embed = occult_embed(description=desc, color="error")
            return await ctx.send(embed=embed, ephemeral=True)

        await ctx.defer(ephemeral=True)

        try:
            # Check if executor can rename the target
            can_do_it, reason = await self.can_rename(ctx.author, member)
            if not can_do_it:
                desc = f"𐄞𐄞 𐄙 access denied 𐄙 𐄞𐄞꒱\n\n𓂃 {reason}"
                embed = occult_embed(description=desc, color="error")
                return await ctx.send(embed=embed, ephemeral=True)

            # Check if bot has permission
            if member.top_role >= ctx.guild.me.top_role:
                desc = f"𐄞𐄞 𐄙 role too high 𐄙 𐄞𐄞꒱\n\n𓂃 i cannot change {member.mention}'s nickname (role too high)"
                embed = occult_embed(description=desc, color="error")
                return await ctx.send(embed=embed, ephemeral=True)

            old_nick = member.nick or member.name

            await member.edit(
                nick=nickname, reason=f"Nickname changed by {ctx.author.name}"
            )

            new_nick = nickname or member.name
            executor_level = await self.get_permission_level(ctx.author)

            desc = f"𐄞𐄞 𐄙 nickname changed 𐄙 𐄞𐄞꒱\n\n"
            desc += f"𓂃 target: {member.mention}\n"
            desc += f"𓂃 changed by: {ctx.author.mention} ({executor_level})\n"
            desc += f"𓂃 old: `{old_nick}`\n"
            desc += f"𓂃 new: `{new_nick}`"

            embed = occult_embed(description=desc, color="success")
            await ctx.send(embed=embed, ephemeral=True)

            logger.log(
                "NICKNAME",
                f"{ctx.author.name} changed {member.name}'s nickname from '{old_nick}' to '{new_nick}'",
            )

            # Log to channel if configured
            log_ch_id = await get_channel_id(self.redis, ctx.guild.id, "log")
            log_ch = self.bot.get_channel(log_ch_id)

            if log_ch:
                log_desc = f"𐄞𐄞 𐄙 nickname changed 𐄙 𐄞𐄞꒱\n\n"
                log_desc += f"𓂃 changed by: {ctx.author.mention} ({executor_level})\n"
                log_desc += f"𓂃 target: {member.mention}\n"
                log_desc += f"𓂃 old: `{old_nick}`\n"
                log_desc += f"𓂃 new: `{new_nick}`"

                log_embed = occult_embed(description=log_desc, color="info")
                await log_ch.send(embed=log_embed)

        except discord.Forbidden:
            desc = f"𐄞𐄞 𐄙 permission error 𐄙 𐄞𐄞꒱\n\n𓂃 i do not have permission to change {member.mention}'s nickname"
            embed = occult_embed(description=desc, color="error")
            await ctx.send(embed=embed, ephemeral=True)
            logger.error(f"Missing permissions to change nickname for {member.name}")
        except Exception as e:
            desc = f"𐄞𐄞 𐄙 error 𐄙 𐄞𐄞꒱\n\n𓂃 {str(e)}"
            embed = occult_embed(description=desc, color="error")
            await ctx.send(embed=embed, ephemeral=True)
            logger.error(f"Failed to change nickname: {e}")


async def setup(bot):
    await bot.add_cog(Nickname(bot))
