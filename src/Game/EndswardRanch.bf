using System;
using System.Collections;
using SDL3;
using SDL3_image;

namespace Manivela_Engine;

class EndswardRanch : IGame
{
    public float WorldWidth { get; set; } = 1920f;
    public float WorldHeight { get; set; } = 1080f;
    public int round = 1;

    Player player = new Player() ~ delete _;
    public List<EnemyStalker> enemies = new .() ~ { for (let e in _) delete e; delete _; };
    public float relativeVelocityX = 0f;
    public float relativeVelocityY = 0f;
    public float impactForce = 0f;
    public float playerKnockback = 0f;
    public float enemyKnockback = 0f;
    public float baseKnockback = 5f;
    public bool shouldRespawnPlayer = false;

    public void Init(Engine engine)
    {
        player.Init(engine);
    }

    public void Update(Engine engine, float delta)
    {
        player.Update(engine, delta, WorldWidth, WorldHeight);

        if (enemies.IsEmpty)
        {
            Random rand = scope .();
            for (int i = 0; i < round; i++)
            {
                EnemyStalker newEnemy = new EnemyStalker();
                newEnemy.Init(engine);
                newEnemy.originalSpeed += (round - 1) * 10;
                
                bool validPosition = false;
                while (!validPosition)
                {
                    float randX = 0;
                    float randY = 0;
                    
                    int edge = (int)(rand.NextDouble() * 4);
                    if (edge == 0) {
                        randX = (float)rand.NextDouble() * (WorldWidth - newEnemy.enemyRect.w);
                        randY = (float)rand.NextDouble() * 100f;
                    } else if (edge == 1) {
                        randX = (float)rand.NextDouble() * (WorldWidth - newEnemy.enemyRect.w);
                        randY = WorldHeight - newEnemy.enemyRect.h - (float)rand.NextDouble() * 100f;
                    } else if (edge == 2) {
                        randX = (float)rand.NextDouble() * 100f;
                        randY = (float)rand.NextDouble() * (WorldHeight - newEnemy.enemyRect.h);
                    } else {
                        randX = WorldWidth - newEnemy.enemyRect.w - (float)rand.NextDouble() * 100f;
                        randY = (float)rand.NextDouble() * (WorldHeight - newEnemy.enemyRect.h);
                    }
                    
                    float dx = player.playerRect.x - randX;
                    float dy = player.playerRect.y - randY;
                    float dist = Math.Sqrt(dx * dx + dy * dy);
                    
                    if (dist > 500f)
                    {
                        newEnemy.enemyRect.x = randX;
                        newEnemy.enemyRect.y = randY;
                        validPosition = true;
                    }
                }
                
                enemies.Add(newEnemy);
            }
            round++;
        }

        player.mana = Math.Min(player.mana + player.manaRegen * delta, player.maxMana);
        player.strength = Math.Min(player.strength + player.strengthRegen * delta, player.maxStrength);

        for (int i = enemies.Count - 1; i >= 0; i--)
        {
            EnemyStalker enemy = enemies[i];
            enemy.Update(engine, delta, player.playerRect, WorldWidth, WorldHeight);

            for (int j = 0; j < enemies.Count; j++)
            {
                if (i == j) continue;
                EnemyStalker other = enemies[j];
                if (SDL_HasRectIntersectionFloat(&enemy.enemyRect, &other.enemyRect))
                {
                    float eCenterX1 = enemy.enemyRect.x + enemy.enemyRect.w / 2f;
                    float eCenterY1 = enemy.enemyRect.y + enemy.enemyRect.h / 2f;
                    float eCenterX2 = other.enemyRect.x + other.enemyRect.w / 2f;
                    float eCenterY2 = other.enemyRect.y + other.enemyRect.h / 2f;

                    float dx = eCenterX1 - eCenterX2;
                    float dy = eCenterY1 - eCenterY2;
                    float length = Math.Sqrt(dx * dx + dy * dy);

                    if (length > 0)
                    {
                        dx /= length;
                        dy /= length;
                        float pushForce = 1000f;
                        enemy.knockbackX += dx * pushForce * delta;
                        enemy.knockbackY += dy * pushForce * delta;
                    }
                }
            }

            for (let p in player.projectiles)
            {
                if (p.active && SDL_HasRectIntersectionFloat(&p.projectileRect, &enemy.enemyRect))
                {
                    if (!p.hitEnemies.Contains(enemy))
                    {
                        p.hitEnemies.Add(enemy);
                        
                        if (p.type != .Fast)
                        {
                            p.active = false;
                        }
                        
                        if (p.type == .Heavy)
                        {
                            float hitX = p.projectileRect.x + p.projectileRect.w / 2f;
                            float hitY = p.projectileRect.y + p.projectileRect.h / 2f;
                            float radius = 350f;
                            
                            for (int j = 0; j < enemies.Count; j++)
                            {
                                EnemyStalker aoeTarget = enemies[j];
                                float eX = aoeTarget.enemyRect.x + aoeTarget.enemyRect.w / 2f;
                                float eY = aoeTarget.enemyRect.y + aoeTarget.enemyRect.h / 2f;
                                
                                float aoeDx = eX - hitX;
                                float aoeDy = eY - hitY;
                                float dist = Math.Sqrt(aoeDx * aoeDx + aoeDy * aoeDy);
                                
                                if (dist <= radius)
                                {
                                    aoeTarget.health -= p.damage;
                                    if (dist > 0)
                                    {
                                        aoeDx /= dist;
                                        aoeDy /= dist;
                                    }
                                    aoeTarget.knockbackX += aoeDx * 4000f * delta;
                                    aoeTarget.knockbackY += aoeDy * 4000f * delta;
                                }
                            }
                        }
                        else
                        {
                            enemy.health -= p.damage;
                        }
                    }
                }
            }

            if (player.melee.meleeState == .Attacking && SDL_HasRectIntersectionFloat(&player.melee.meleeRect, &enemy.enemyRect) && !player.melee.hasHit)
            {
                enemy.health -= player.melee.damage;
                player.melee.hasHit = true;
                
                if (player.currentMelee == .Dagger)
                {
                    player.health = Math.Min(player.health + 5f, player.maxHealth);
                }
                else if (player.currentMelee == .Mace)
                {
                    enemy.speed -= 50f;
                }
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

            if (enemy.health <= 0)
            {
                delete enemy;
                enemies.RemoveAt(i);
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
            for (let e in enemies) delete e;
            enemies.Clear();
            shouldRespawnPlayer = false;
            round = 1;
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
        
        if (ev.type == (.)SDL_EventType.SDL_EVENT_KEY_DOWN && ev.key.repeat == false)
        {
            if (ev.key.scancode == (.)SDL_Scancode.SDL_SCANCODE_Q)
                player.CycleProjectile();
            
            if (ev.key.scancode == (.)SDL_Scancode.SDL_SCANCODE_E)
                player.CycleMelee();
        }
    }

    public void Draw(Engine engine)
    {
        player.Draw(engine);
        for (let e in enemies) e.Draw(engine);
        player.gameHud.DrawRoundNumber(engine, round, WorldWidth);
    }

    public void Shutdown()
    {
        player.Shutdown();
        for (let e in enemies) e.Shutdown();
    }
}
