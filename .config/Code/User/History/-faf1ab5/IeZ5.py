"""
Configuration Module
Loads and parses environment variables for the bot
"""

import os
from typing import List
from dotenv import load_dotenv
from logger import logger

load_dotenv()


def parse_comma_separated_ids(env_var: str, var_name: str) -> List[int]:
    """Parse comma-separated IDs from environment variable."""
    if not env_var or env_var.strip() == "":
        return []

    try:
        id_strings = [s.strip() for s in env_var.split(",") if s.strip()]
        ids = [int(id_str) for id_str in id_strings]
        # console.print(f"[green][ENV]:[/green] Loaded {len(ids)} IDs for {var_name}")
        logger.log("ENV", f"Loaded {len(ids)} IDs for {var_name}")
        return ids
    except ValueError as e:
        # console.print(f"[red][ENV ERROR]:[/red] Invalid ID format in {var_name}: {e}")
        logger.log("ENV ERROR", f"Invalid ID format in {var_name}: {e}", "red")
        return []


# Bot token
BOT_TOKEN = os.getenv("BOT_TOKEN")
if BOT_TOKEN is None:
    raise ValueError("BOT_TOKEN not found in environment variables")

# Bot owner IDs
BOT_OWNER_IDS = parse_comma_separated_ids(os.getenv("BOT_OWNER_ID", ""), "BOT_OWNER_ID")
if not BOT_OWNER_IDS:
    raise ValueError("BOT_OWNER_ID not found or invalid in environment variables")

# Parse comma-separated role IDs
AGE_ROLE_IDS = parse_comma_separated_ids(os.getenv("AGE_ROLE_IDS", ""), "AGE_ROLE_IDS")
GENDER_ROLE_IDS = parse_comma_separated_ids(
    os.getenv("GENDER_ROLE_IDS", ""), "GENDER_ROLE_IDS"
)
PING_ROLE_IDS = parse_comma_separated_ids(
    os.getenv("PING_ROLE_IDS", ""), "PING_ROLE_IDS"
)
HEX_ROLE_IDS = parse_comma_separated_ids(os.getenv("HEX_ROLE_IDS", ""), "HEX_ROLE_IDS")

# Redis configuration
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", None)


# Helper functions
def is_bot_owner(user_id: int) -> bool:
    """Check if user ID is in the bot owners list"""
    return user_id in BOT_OWNER_IDS
