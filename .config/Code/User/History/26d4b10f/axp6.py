from cult import *

COG_VERSION = "2.0.0"
LAST_UPDATE = "2025-02-18 - Move to category instead of delete, proper lockdown"


class Nuker(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.redis = get_redis_manager()
        self.active_nukes = {}
        logger.log("LOADED", f"Nuker system initialized (v{COG_VERSION})")

    async def cog_load(self):
        logger.log("LOADED", f"Nuker v{COG_VERSION} loaded")

    async def cog_unload(self):
        logger.log("LOADED", "Nuker cog unloaded")

    @commands.hybrid_command(name="nuke", description="Nuke a channel (Owner+ only)")
    @app_commands.describe(channel="Channel to nuke")
    @commands.cooldown(1, 60, commands.BucketType.guild)
    async def nuke(self, ctx: commands.Context, channel: discord.TextChannel):
        if not self.redis.is_cog_active_guild(ctx.guild.id, "nuker"):
            embed = occult_embed(
                description="𐄞𐄞 𐄙 nuker paused 𐄙 𐄞𐄞\n\n𓂃 cog is inactive",
                color="error",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        await ctx.defer(ephemeral=True)

        if not await is_authorized(self.redis, ctx.author, ctx.guild.id, "owner"):
            embed = occult_embed(
                description="𐄞𐄞 𐄙 access denied 𐄙 𐄞𐄞\n\n𓂃 owner+ permission required",
                color="error",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        if channel.id in self.active_nukes:
            embed = occult_embed(
                description=f"𐄞𐄞 𐄙 already nuking 𐄙 𐄞𐄞\n\n𓂃 already being nuked",
                color="error",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        purge_cat_id = await get_category_id(self.redis, ctx.guild.id, "general-purge")
        purge_category = ctx.guild.get_channel(purge_cat_id) if purge_cat_id else None

        if not purge_category:
            embed = occult_embed(
                description="𐄞𐄞 𐄙 no purge category 𐄙 𐄞𐄞\n\n𓂃 set with: $set category general-purge <id>",
                color="error",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        self.active_nukes[channel.id] = "starting"
        original_name = channel.name

        try:
            staff_role_id = await get_role_id(self.redis, ctx.guild.id, "staff")
            mod_role_id = await get_role_id(self.redis, ctx.guild.id, "moderator")
            owner_role_id = await get_role_id(self.redis, ctx.guild.id, "owner")
            cult_role_id = await get_role_id(self.redis, ctx.guild.id, "cult")

            staff_role = ctx.guild.get_role(staff_role_id) if staff_role_id else None
            mod_role = ctx.guild.get_role(mod_role_id) if mod_role_id else None
            owner_role = ctx.guild.get_role(owner_role_id) if owner_role_id else None
            cult_role = ctx.guild.get_role(cult_role_id) if cult_role_id else None

            self.active_nukes[channel.id] = "duplicating"
            overwrites = {t: o for t, o in channel.overwrites.items()}

            new_channel = await ctx.guild.create_text_channel(
                name=original_name,
                category=channel.category,
                topic=channel.topic,
                slowmode_delay=channel.slowmode_delay,
                nsfw=channel.nsfw,
                position=channel.position,
                overwrites=overwrites,
                reason=f"Nuke by {ctx.author}",
            )
            logger.log("NUKER", f"Created duplicate #{new_channel.name}")

            self.active_nukes[channel.id] = "renaming"
            nuked_name = f"{original_name}-nuked"
            await channel.edit(name=nuked_name, reason=f"Nuke by {ctx.author}")
            logger.log("NUKER", f"Renamed to #{nuked_name}")

            self.active_nukes[channel.id] = "locking"

            for target in list(channel.overwrites.keys()):
                await channel.set_permissions(
                    target, overwrite=None, reason="Nuke lockdown"
                )
                await asyncio.sleep(0.3)

            await channel.set_permissions(
                ctx.guild.default_role,
                view_channel=False,
                send_messages=False,
                reason="Nuke lockdown",
            )

            if cult_role:
                await channel.set_permissions(
                    cult_role,
                    view_channel=False,
                    send_messages=False,
                    reason="Nuke lockdown",
                )

            if owner_role:
                await channel.set_permissions(
                    owner_role,
                    view_channel=True,
                    send_messages=True,
                    reason="Nuke lockdown",
                )

            if staff_role:
                await channel.set_permissions(
                    staff_role,
                    view_channel=True,
                    send_messages=True,
                    reason="Nuke lockdown",
                )

            if mod_role:
                await channel.set_permissions(
                    mod_role,
                    view_channel=True,
                    send_messages=False,
                    reason="Nuke lockdown",
                )

            logger.log("NUKER", f"Locked down #{nuked_name}")

            self.active_nukes[channel.id] = "moving"
            await channel.edit(category=purge_category, reason=f"Nuke by {ctx.author}")
            logger.log("NUKER", f"Moved #{nuked_name} to {purge_category.name}")

            desc = f"𐄞𐄞 𐄙 nuke complete 𐄙 𐄞𐄞\n\n𓂃 new channel: {new_channel.mention}\n𓂃 old channel: #{nuked_name}\n𓂃 moved to: {purge_category.name}"
            embed = occult_embed(
                description=desc, color="success", guild_id=ctx.guild.id
            )
            await ctx.send(embed=embed, ephemeral=True)

            notify_embed = occult_embed(
                description=f"𐄞𐄞 𐄙 channel nuked 𐄙 𐄞𐄞\n\n𓂃 nuked by: {ctx.author.mention}",
                color="info",
                guild_id=ctx.guild.id,
            )
            await new_channel.send(embed=notify_embed)

        except discord.Forbidden as e:
            logger.error(f"Permission error: {e}")
            embed = occult_embed(
                description=f"𐄞𐄞 𐄙 permission error 𐄙 𐄞𐄞\n\n𓂃 {str(e)}",
                color="error",
                guild_id=ctx.guild.id,
            )
            await ctx.send(embed=embed, ephemeral=True)
        except Exception as e:
            logger.error(f"Nuke error: {e}")
            embed = occult_embed(
                description=f"𐄞𐄞 𐄙 error 𐄙 𐄞𐄞\n\n𓂃 {str(e)}",
                color="error",
                guild_id=ctx.guild.id,
            )
            await ctx.send(embed=embed, ephemeral=True)
        finally:
            if channel.id in self.active_nukes:
                del self.active_nukes[channel.id]

    @commands.hybrid_command(
        name="nukestatus", description="Check active nukes (Staff+ only)"
    )
    async def nukestatus(self, ctx: commands.Context):
        if not self.redis.is_cog_active_guild(ctx.guild.id, "nuker"):
            embed = occult_embed(
                description="𐄞𐄞 𐄙 nuker paused 𐄙 𐄞𐄞\n\n𓂃 cog is inactive",
                color="error",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        await ctx.defer(ephemeral=True)

        if not await is_authorized(self.redis, ctx.author, ctx.guild.id, "staff"):
            embed = occult_embed(
                description="𐄞𐄞 𐄙 access denied 𐄙 𐄞𐄞\n\n𓂃 staff+ required",
                color="error",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        if not self.active_nukes:
            embed = occult_embed(
                description="𐄞𐄞 𐄙 nuke status 𐄙 𐄞𐄞\n\n𓂃 no active nukes",
                color="info",
                guild_id=ctx.guild.id,
            )
            return await ctx.send(embed=embed, ephemeral=True)

        lines = [f"𓂃 <#{cid}>: {status}" for cid, status in self.active_nukes.items()]
        embed = occult_embed(
            description="𐄞𐄞 𐄙 nuke status 𐄙 𐄞𐄞\n\n" + "\n".join(lines),
            color="info",
            guild_id=ctx.guild.id,
        )
        await ctx.send(embed=embed, ephemeral=True)


async def setup(bot):
    await bot.add_cog(Nuker(bot))
