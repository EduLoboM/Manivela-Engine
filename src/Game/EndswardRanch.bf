using System;
using SDL3;
using SDL3_image;

namespace Manivela_Engine;

class EndswardRanch : IGame
{
    Player player = new Player() ~ delete _;
    EnemyStalker enemy = new EnemyStalker() ~ delete _;
    public float relativeVelocityX = 0f;
    public float relativeVelocityY = 0f;
    public float impactForce = 0f;
    public float playerKnockback = 0f;
    public float enemyKnockback = 0f;
    public float baseKnockback = 5f;
    public bool shouldRespawnEnemy = false;
    public bool shouldRespawnPlayer = false;

    public void Init(Engine engine)
    {
        player.Init(engine);
        enemy.Init(engine);
    }

    public void Update(Engine engine, float delta)
    {
        player.Update(engine, delta);
        enemy.Update(engine, delta, player.playerRect);

        player.mana = Math.Min(player.mana + player.manaRegen * delta, player.maxMana);
        player.strength = Math.Min(player.strength + player.strengthRegen * delta, player.maxStrength);

        for (let p in player.projectiles)
        {
            if (p.active && SDL_HasRectIntersectionFloat(&p.projectileRect, &enemy.enemyRect))
            {
                p.active = false;
                enemy.health -= p.damage;
                if (enemy.health <= 0)
                {
                    shouldRespawnEnemy = true;
                }
            }
        }

        if (player.melee.meleeState == .Attacking && SDL_HasRectIntersectionFloat(&player.melee.meleeRect, &enemy.enemyRect) && !player.melee.hasHit)
        {
            enemy.health -= player.melee.damage;
            player.melee.hasHit = true;
            if (enemy.health <= 0)
            {
                shouldRespawnEnemy = true;
            }
        }

        if (shouldRespawnEnemy)
        {
            delete enemy;
            enemy = new EnemyStalker();
            enemy.Init(engine);
            shouldRespawnEnemy = false;
        }

        if (SDL_HasRectIntersectionFloat(&player.playerRect, &enemy.enemyRect))
        {
            float pCenterX = player.playerRect.x + player.playerRect.w / 2f;
            float pCenterY = player.playerRect.y + player.playerRect.h / 2f;
            float eCenterX = enemy.enemyRect.x + enemy.enemyRect.w / 2f;
            float eCenterY = enemy.enemyRect.y + enemy.enemyRect.h / 2f;

            float dx = pCenterX - eCenterX;
            float dy = pCenterY - eCenterY;
            float length = Math.Sqrt(dx * dx + dy * dy);

            if (player.invincibility < 0)
            {
                player.hasFlash = true;
                player.health -= enemy.damage;
                player.invincibility = 1.5f;
            }
            
            if (player.health <= 0)
            {
                shouldRespawnPlayer = true;
            }

            if (length > 0)
            {
                dx /= length;
                dy /= length;
                
                float pushForce = 2000f;
                
                float totalMass = player.mass + enemy.mass;
                float pRatio = enemy.mass / totalMass;
                float eRatio = player.mass / totalMass;

                player.knockbackX += dx * pushForce * pRatio * delta;
                player.knockbackY += dy * pushForce * pRatio * delta;

                enemy.knockbackX -= dx * pushForce * eRatio * delta;
                enemy.knockbackY -= dy * pushForce * eRatio * delta;
            }
        }

        for (int i = player.projectiles.Count - 1; i >= 0; i--)
        {
            Projectile p = player.projectiles[i];
            if (!p.active)
            {
                player.projectiles.Remove(p);
                delete p;
            }
        }

        player.invincibility -= delta;

        if (shouldRespawnPlayer)
        {
            delete player;
            player = new Player();
            player.Init(engine);
            shouldRespawnPlayer = false;
        }
    }

    public void OnEvent(Engine engine, SDL_Event ev)
    {
        if (ev.type == (.)SDL_EventType.SDL_EVENT_MOUSE_BUTTON_DOWN)
        {
            if (ev.button.button == (.)SDL_MouseButtonFlags.SDL_BUTTON_LEFT)
                player.Shoot(engine);
            if (ev.button.button == (.)SDL_MouseButtonFlags.SDL_BUTTON_RIGHT)
                player.Attack(engine);
        }
    }

    public void Draw(Engine engine)
    {
        player.Draw(engine);
        enemy.Draw(engine);
    }

    public void Shutdown()
    {
        player.Shutdown();
        enemy.Shutdown();
    }
}
