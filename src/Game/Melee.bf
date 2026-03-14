using System;
using SDL3;
using SDL3_image;
namespace Manivela_Engine;

public enum MeleeType {
    Sword,
    Dagger,
    Mace
}

class Melee
{

    SDL_Texture* meleeTexture;
    public SDL_FRect meleeRect = .() { x = 400, y = 300, w = 250, h = 100};
    public float duration = 0.25f;
    public float damage = 34f;
    public float strengthCost = 15f;
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

    public void Equip(MeleeType type, Engine engine)
    {
        if (meleeTexture != null)
            SDL_DestroyTexture(meleeTexture);
        switch (type)
        {
            case .Sword:
                meleeTexture = IMG_LoadTexture(engine.Renderer, "assets/sword.png");
                damage = 34f;
                strengthCost = 15f;
                duration = 0.25f;
                cooldown = 0.25f;
                meleeRect.w = 250;
                meleeRect.h = 100;
            case .Dagger:
                meleeTexture = IMG_LoadTexture(engine.Renderer, "assets/dagger.png");
                damage = 15f;
                strengthCost = 5f;
                duration = 0.1f;
                cooldown = 0.1f;
                meleeRect.w = 150;
                meleeRect.h = 50;
            case .Mace:
                meleeTexture = IMG_LoadTexture(engine.Renderer, "assets/hammer.png");
                damage = 80f;
                strengthCost = 40f;
                duration = 0.5f;
                cooldown = 0.8f;
                meleeRect.w = 300;
                meleeRect.h = 150;
        }
    }

    public void Init(Engine engine)
    {
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

    public void Draw(Engine engine, float alpha)
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
