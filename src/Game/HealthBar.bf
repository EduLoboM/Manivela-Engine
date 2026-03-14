using System;
using SDL3;
using SDL3_image;
namespace Manivela_Engine;

class HealthBar
{

    public void Update(float delta)
    {

    }

    public void Draw(Engine engine, float health, float maxHealth, float x, float y, float w, float h, float scale)
    {
        SDL_FRect healthBackground = .() { x = x, y = y, w = (maxHealth/scale) * w, h = h };
        SDL_FRect healthBar = .() { x = x, y = y, w = (health/scale) * w, h = h };

        SDL_SetRenderDrawColor(engine.Renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(engine.Renderer, &healthBackground);
        if (health > maxHealth * 0.6f)
        {
            SDL_SetRenderDrawColor(engine.Renderer, 0, 255, 0, 255);
        }
        else if (health > maxHealth * 0.3f)
        {
            SDL_SetRenderDrawColor(engine.Renderer, 255, 255, 0, 255);
        }
        else
        {
            SDL_SetRenderDrawColor(engine.Renderer, 255, 30, 30, 255);
        }
        SDL_RenderFillRect(engine.Renderer, &healthBar);
    }

    public void Shutdown()
    {

    }
}
