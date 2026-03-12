using System;
using SDL3;
using SDL3_image;

namespace Manivela_Engine;

class EnemyStalker
{
    SDL_Texture* enemyTexture;
    public SDL_FRect enemyRect = .() { x = 1780, y = 1000, w = 150, h = 203 };
    public float speed = 100f;
    public float mass = 1f;
    public float health = 100f;
    public float maxHealth = 100f;
    public float damage = 25f;
    public float dirX = 0f;
    public float dirY = 0f;
    public float knockbackX = 0f;
    public float knockbackY = 0f;
    public float friction = 5.0f;

    Healthbar healthbar = new Healthbar();

    public void Init(Engine engine)
    {
        enemyTexture = IMG_LoadTexture(engine.Renderer, "assets/Enemy.png");
        if (enemyTexture == null){
            Console.WriteLine("Failed to load enemy texture!");
        }
    }

    public void Update(Engine engine, float delta, SDL_FRect playerRect)
    {
        dirX = playerRect.x - enemyRect.x;
        dirY = playerRect.y - enemyRect.y;
        float length = Math.Sqrt(dirX * dirX + dirY * dirY);
        if (length > 0)
        {
            dirX /= length;
            dirY /= length;
        }

        enemyRect.x = Math.Clamp(enemyRect.x, 0, 1780 - enemyRect.w);
        enemyRect.y = Math.Clamp(enemyRect.y, 0, 1000 - enemyRect.h);
        
        float velocityX = dirX * speed + knockbackX;
        float velocityY = dirY * speed + knockbackY;
        
        knockbackX = Math.Lerp(knockbackX, 0f, friction * delta);
        knockbackY = Math.Lerp(knockbackY, 0f, friction * delta);
        
        enemyRect.x += velocityX * delta;
        enemyRect.y += velocityY * delta;
    }

    public void Draw(Engine engine)
    {
        if (enemyTexture != null)
            SDL_RenderTexture(engine.Renderer, enemyTexture, null, &enemyRect);

        healthbar.Draw(engine, health, maxHealth, enemyRect.x, enemyRect.y - 20, enemyRect.w, 5, 100);
    }

    public void Shutdown()
    {
        if (enemyTexture != null)
            SDL_DestroyTexture(enemyTexture);
    }
}