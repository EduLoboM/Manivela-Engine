using System;
using System.Collections;
using SDL3;
using SDL3_image;
namespace Manivela_Engine;

public enum ProjectileType {
    Normal,
    Fast,
    Heavy
}

class Projectile
{

    SDL_Texture* projectileTexture;
    public SDL_FRect projectileRect = .() { x = 400, y = 300, w = 20, h = 20 };
    public float speed = 1000f;
    public float damage = 10f;
    public float mass = 1f;
    public float prevX = 0f;
    public float prevY = 0f;
    public float dirX = 0f;
    public float dirY = 0f;
    public bool active = false;
    public float manaCost = 15f;
    public ProjectileType type;
    public List<EnemyStalker> hitEnemies = new .() ~ delete _;

    public this(ProjectileType type)
    {
        this.type = type;
        switch (type)
        {
            case .Normal:
                speed = 1000f;
                damage = 10f;
                manaCost = 15f;
                projectileRect.w = 20;
                projectileRect.h = 20;
            case .Fast:
                speed = 2000f;
                damage = 5f;
                manaCost = 10f;
                projectileRect.w = 10;
                projectileRect.h = 10;
            case .Heavy:
                speed = 500f;
                damage = 35f;
                manaCost = 30f;
                projectileRect.w = 40;
                projectileRect.h = 40;
        }
    }

    public static float getManaCost(ProjectileType type)
    {
        switch (type)
        {
            case .Normal:
                return 15f;
            case .Fast:
                return 5f;
            case .Heavy:
                return 30f;
        }
    }

    public void Update(float delta, float WorldWidth, float WorldHeight)
    {
        prevX = projectileRect.x;
        prevY = projectileRect.y;
        projectileRect.x += dirX * speed * delta;
        projectileRect.y += dirY * speed * delta;

        if (projectileRect.x < 0 || projectileRect.x > WorldWidth || projectileRect.y < 0 || projectileRect.y > WorldHeight){
            active = false;
        }
        
    }
    public void Draw(Engine engine, float alpha)
    {
        float drawX = prevX + (projectileRect.x - prevX) * alpha;
        float drawY = prevY + (projectileRect.y - prevY) * alpha;
        SDL_FRect drawRect = projectileRect;
        drawRect.x = drawX;
        drawRect.y = drawY;
        SDL_RenderFillRect(engine.Renderer, &drawRect);
    }
}
