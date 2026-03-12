using System;
using SDL3;
using SDL3_image;
namespace Manivela_Engine;

class Melee
{

    SDL_Texture* meleeTexture;
    public SDL_FRect meleeRect = .() { x = 400, y = 300, w = 250, h = 100};
    public float duration = 0.25f;
    public float damage = 34f;
    public enum MeleeState {
        Ready,
        Attacking,
        Cooldown
    }
    public MeleeState meleeState = .Ready;
    float timer = 0f;
    public float cooldown = 0.25f;
    double angle = 0;
    public bool hasHit = false;

    public void Init(Engine engine)
    {
        meleeTexture = SDL_CreateTexture(engine.Renderer, .SDL_PIXELFORMAT_RGBA8888, .SDL_TEXTUREACCESS_TARGET, 1, 1);
        if (meleeTexture != null)
        {
            SDL_SetRenderTarget(engine.Renderer, meleeTexture);
            SDL_SetRenderDrawColor(engine.Renderer, 255, 255, 255, 255);
            SDL_RenderClear(engine.Renderer);
            SDL_SetRenderTarget(engine.Renderer, null);
            SDL_SetTextureColorMod(meleeTexture, 255, 0, 0);
        }
    }

    public void Attack(SDL_FRect entityRect, float dirX, float dirY)
    {
        if (meleeState == .Ready)
        {
            meleeState = .Attacking;
            timer = duration;
            meleeRect.x = entityRect.x + entityRect.w / 2f - meleeRect.w / 2f;
            meleeRect.y = entityRect.y + entityRect.h / 2f - meleeRect.h / 2f;
            meleeRect.x += dirX * entityRect.w / 2f;
            meleeRect.y += dirY * entityRect.h / 2f;
            angle = Math.Atan2(dirY, dirX) * (180.0 / Math.PI_d);
            hasHit = false;
        }
    }

    public void Update(float delta)
    {
        if (meleeState == .Attacking)
        {
            timer -= delta;
            if (timer <= 0)
            {
                meleeState = .Cooldown;
                timer = cooldown;
            }
        }
        else if (meleeState == .Cooldown)
        {
            timer -= delta;
            if (timer <= 0)
            {
                meleeState = .Ready;
                timer = 0;
            }
        }
    }

    public void Draw(Engine engine)
    {
        if (meleeState == .Attacking && meleeTexture != null)
        {
            SDL_RenderTextureRotated(engine.Renderer, meleeTexture, null, &meleeRect, angle, null, .SDL_FLIP_NONE);
        }
    }

    public void Shutdown()
    {
        if (meleeTexture != null)
            SDL_DestroyTexture(meleeTexture);
    }
}
