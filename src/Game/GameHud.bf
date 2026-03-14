using System;
using SDL3;
using SDL3_image;
namespace Manivela_Engine;

class GameHud
{

    public void Update(float delta)
    {

        
    }

    public void Draw(Engine engine, float mana, float maxMana, float x, float y, float w, float h, float scale, float strength, float maxStrength)
    {
        SDL_FRect manaBackground = .() { x = x, y = y, w = (maxMana/scale) * w, h = h };
        SDL_FRect manaBar = .() { x = x, y = y, w = (mana/scale) * w, h = h };

        SDL_SetRenderDrawColor(engine.Renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(engine.Renderer, &manaBackground);
        if (mana > maxMana * 0.6f)
        {
            SDL_SetRenderDrawColor(engine.Renderer, 0, 255, 209, 255);
        }
        else if (mana > maxMana * 0.3f)
        {
            SDL_SetRenderDrawColor(engine.Renderer, 255, 255, 0, 255);
        }
        else
        {
            SDL_SetRenderDrawColor(engine.Renderer, 255, 30, 30, 255);
        }
        SDL_RenderFillRect(engine.Renderer, &manaBar);

        SDL_FRect strengthBackground = .() { x = x, y = y + 5, w = (maxStrength/scale) * w, h = h };
        SDL_FRect strengthBar = .() { x = x, y = y + 5, w = (strength/scale) * w, h = h };


        SDL_SetRenderDrawColor(engine.Renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(engine.Renderer, &strengthBackground);
        if (strength > maxStrength * 0.6f)
        {
            SDL_SetRenderDrawColor(engine.Renderer, 0, 255, 209, 255);
        }
        else if (strength > maxStrength * 0.3f)
        {
            SDL_SetRenderDrawColor(engine.Renderer, 255, 255, 0, 255);
        }
        else
        {
            SDL_SetRenderDrawColor(engine.Renderer, 255, 30, 30, 255);
        }
        SDL_RenderFillRect(engine.Renderer, &strengthBar);
    }
    
    public void DrawRoundNumber(Engine engine, int round, float WorldWidth)
    {
        String roundText = scope .();
        roundText.AppendF("WAVE {0}", round - 1);
        
        SDL_SetRenderDrawColor(engine.Renderer, 0, 0, 0, 255);
        
        float textScale = 3.0f;
        SDL_SetRenderScale(engine.Renderer, textScale, textScale);
        
        float textW = (float)(roundText.Length * 8);
        float textX = ((WorldWidth / 2f) / textScale) - (textW / 2f);
        float textY = 20f / textScale;
        
        SDL_RenderDebugText(engine.Renderer, textX, textY, roundText.CStr());
        
        SDL_SetRenderScale(engine.Renderer, 1.0f, 1.0f);
    }

    public void Shutdown()
    {

    }
}
