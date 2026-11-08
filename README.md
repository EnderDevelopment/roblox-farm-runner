# Roblox Farming Game Script: Run a Farm

Run a Farm is a self-contained Roblox farming game script that provides a complete farming game loop with generated soil plots, planting, watering, crop growth, harvesting, coins, ProximityPrompt interactions, leaderstats, a sign, crop visuals, and a client HUD.

## Install

1. Open Roblox Studio and create or open a place.
2. In `ServerScriptService`, create a `Script` named `FarmGame`.
3. Copy the contents of `ServerScriptService/FarmGame.server.lua` into the new server script.
4. In `StarterPlayer > StarterPlayerScripts`, create a `LocalScript` named `FarmClient`.
5. Copy the contents of `StarterPlayer/StarterPlayerScripts/FarmClient.client.lua` into the new local script.
6. Press Play to test the game.

The server script automatically creates the farm folder, twelve plots, the farm sign, crop visuals, ProximityPrompts, remotes, and player leaderstats.

## Use

1. Walk to an empty soil plot.
2. Activate the `Plant Seed` prompt to start growing a crop.
3. Activate the `Water Crop` prompt while the crop is growing.
4. Watering reduces the remaining growth time and temporarily changes the crop visual.
5. Wait for the prompt to change to `Harvest Crop`.
6. Activate `Harvest Crop` to receive 15 coins.
7. Plant another seed and continue farming.
8. Check the HUD and Roblox leaderboard to view the player’s current coins.

Players begin with 25 coins. Crops normally grow for 45 seconds, and each crop can be watered once every 18 seconds. The server controls plot states and coin rewards, while the client script creates the HUD and displays status messages.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/690e3ded-7599-47b0-a9e3-712445ed08b1?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=690e3ded-7599-47b0-a9e3-712445ed08b1
