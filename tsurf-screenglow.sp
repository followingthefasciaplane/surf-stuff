//https://github.com/bcserv/smlib/blob/master/scripting/include/smlib/effects.inc
#include <sourcemod>
#include <sdktools>
#include <smlib/effects>

#define SPRITE_MODEL "sprites/blueglow1.vmt" // Choose the model

bool g_showSprite[MAXPLAYERS + 1];
int g_spriteModelIndex;

public void OnPluginStart()
{
    // Precache the sprite model and store the model index
    g_spriteModelIndex = PrecacheModel(SPRITE_MODEL);
}

public void OnTrickCompleted(int client)
{
    // Set the sprite visibility to true when the trick is completed
    g_showSprite[client] = true;

    // Get client eye position
    float eyePosition[3];
    GetClientEyePosition(client, eyePosition);

    // Offset to move the sprite slightly in front of the player's view
    float offset[3];
    offset[0] = eyePosition[0] + 0.0;  // Move forward, no idea what these should be set to
    offset[1] = eyePosition[1];
    offset[2] = eyePosition[2] - 0.0;  // Move down

    // Create Effect_EnvSprite
    int sprite = Effect_EnvSprite(
        offset,                 // Spawn the sprite at the offset from eye angles
        g_spriteModelIndex,     // Pass the precached model index directly
        {255, 255, 255, 255},   // Color (R, G, B, A)
        0.5,                    // Scale
        "",                     // Target name, irrelevant for now anyway
        client,                 // Set parent to client to make the sprite follow the client until it is gone
        RENDER_WORLDGLOW,       // Render mode
        RENDERFX_NONE,          // Render fx
        2.0,                    // Radius size of the glow when to be rendered, if inside a geometry
        10.0,                   // Sprite frame rate
        1.0,                    // Multiply sprite color by this when running with HDR
        false                   // Sprite doesn't need shadows
    );

    if (sprite != INVALID_ENT_REFERENCE)
    {
        // Initiate the fade-out effect to make the sprite disappear gradually
        bool fadeSuccess = Effect_Fade(
            sprite,                 // Entity index
            true,                   // Fade out
            true,                   // Kill entity after fadeout
            true,                   // Fade out fast
            ResetSpriteCallback,    // Callback to reset g_showSprite
            client                  // Pass client to callback
        );

        if (!fadeSuccess)
        {
            // Handle the case when the fade effect fails
            PrintToServer("Failed to initiate the fade effect for the sprite.");
            // You can add additional error handling or logging here
        }
    }
}

public void ResetSpriteCallback(int client)
{
    // Reset the sprite visibility
    g_showSprite[client] = false;
}
