using System;
using System.Collections;
using SDL3;
using SDL3_image;

namespace Manivela_Engine;

class Player
{
    public List<Projectile> projectiles = new .() ~ delete _;
    SDL_Texture* playerTexture;
    public SDL_FRect playerRect = .() { x = 0, y = 0, w = 147, h = 201 };
    public float speed = 200f;
    public float mass = 1f;
    public float velocityX = 0f;
    public float velocityY = 0f;
    public float knockbackX = 0f;
    public float knockbackY = 0f;
    public float friction = 5.0f;
    public float health = 100f;
    public float maxHealth = 100f;
    public float invincibility = 0f;
    public bool hasFlash = false;

    public float maxMana = 100f;
    public float mana = 100f;
    public float manaRegen = 10f;
    public float maxStrength = 100f;
    public float strength = 100f;
    public float strengthRegen = 5f;

    public GameHud gameHud = new GameHud() ~ delete _;
    public HealthBar healthbar = new HealthBar() ~ delete _;
    public Melee melee = new Melee() ~ delete _;

    DashState dashState = .Ready;
    float dashTimer = 0f;
    float dashSpeed = 800;
    float dashDuration = 0.5f;
    float dashCooldown = 1.0f;
    float dashDirX = 0f;
    float dashDirY = 0f;
    
    enum DashState {
        Ready,
        Dashing,
        Cooldown
    }

    public MeleeType currentMelee = .Sword;
    public ProjectileType currentProjectile = .Normal;

    public void Init(Engine engine)
    {
        playerTexture = IMG_LoadTexture(engine.Renderer, "assets/Player.png");
        if (playerTexture == null)
            Console.WriteLine("Failed to load player texture!");
        melee.Init(engine);
        melee.Equip(currentMelee);
    }

    public void Update(Engine engine, float delta, float WorldWidth, float WorldHeight)
    {
        velocityX = 0f;
        velocityY = 0f;

        if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_W]){
            velocityY -= speed;
        }
        if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_S]){
            velocityY += speed;
        }
        if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_A]){
            velocityX -= speed;
        }
        if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_D]){
            velocityX += speed;
        }

        for (let p in projectiles)
        {
            if (p.active)
                p.Update(delta, WorldWidth, WorldHeight);
        }
        
        velocityX += knockbackX;
        velocityY += knockbackY;
        
        knockbackX = Math.Lerp(knockbackX, 0f, friction * delta);
        knockbackY = Math.Lerp(knockbackY, 0f, friction * delta);

        playerRect.x += velocityX * delta;
        playerRect.y += velocityY * delta;

        playerRect.x = Math.Clamp(playerRect.x, 0, WorldWidth - playerRect.w);
        playerRect.y = Math.Clamp(playerRect.y, 0, WorldHeight - playerRect.h);
        
        if (dashState == .Ready && engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_LSHIFT])
        {
            dashState = .Dashing;
            if (invincibility < 0){
                hasFlash = false;
            }
            dashTimer = 0;
            dashDirX = 0;
            dashDirY = 0;
            if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_W])
                dashDirY = -1;
            if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_S])
                dashDirY = 1;
            if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_A])
                dashDirX = -1;
            if (engine.KeyboardState[(int)SDL_Scancode.SDL_SCANCODE_D])
                dashDirX = 1;
            float length = Math.Sqrt(dashDirX * dashDirX + dashDirY * dashDirY);
            if (length > 0)
            {
                dashDirX /= length;
                dashDirY /= length;
            }
        }

        if (dashState == .Dashing)
        {
            dashTimer += delta;
            invincibility = Math.Max(dashDuration, invincibility);
            if (dashTimer < dashDuration)
            {
                playerRect.x += dashDirX * dashSpeed * delta;
                playerRect.y += dashDirY * dashSpeed * delta;
                velocityX += dashDirX * dashSpeed * delta;
                velocityY += dashDirY * dashSpeed * delta;
            }
            else
            {
                dashState = .Cooldown;
                dashTimer = 0;
            }
        }
        else if (dashState == .Cooldown)
        {
            dashTimer += delta;
            if (dashTimer >= dashCooldown)
            {
                dashState = .Ready;
                dashTimer = 0;
            }
        }

        melee.Update(delta);
    }

    public void Draw(Engine engine)
    {
        if (invincibility > 0 && hasFlash)
        {
            if ((int)(invincibility * 10) % 2 == 0)
            {
                SDL_SetTextureColorMod(playerTexture, 128, 128, 128);
            } else {
                SDL_SetTextureColorMod(playerTexture, 255, 255, 255);
            }
        } else {
            SDL_SetTextureColorMod(playerTexture, 255, 255, 255);
        }
        if (playerTexture != null)
            SDL_RenderTexture(engine.Renderer, playerTexture, null, &playerRect);

        healthbar.Draw(engine, health, maxHealth, 25, 25, playerRect.w, 5, 50);
        gameHud.Draw(engine, mana, maxMana, 25, 35, playerRect.w, 5, 50, strength, maxStrength);
        SDL_SetRenderDrawColor(engine.Renderer, 198, 57, 125, 255);

        for (let p in projectiles)
        {
            if (p.active)
            SDL_RenderFillRect(engine.Renderer, &p.projectileRect);
        }
        melee.Draw(engine);
    }

    public void Shoot(Engine engine)
    {
        float cost = Projectile.getManaCost(currentProjectile);
        if (mana < cost)
            return;

        float mouseX = 0f;
        float mouseY = 0f;
        SDL_GetMouseState(&mouseX, &mouseY);
        float dx = mouseX - (playerRect.x + playerRect.w / 2f);
        float dy = mouseY - (playerRect.y + playerRect.h / 2f);
        float length = Math.Sqrt(dx * dx + dy * dy);
        
        if (length > 0)
        {
            dx /= length;
            dy /= length;
        }
        
        Projectile p = new Projectile(currentProjectile);
        mana -= p.manaCost;
        p.dirX = dx;
        p.dirY = dy;
        
        p.projectileRect.x = playerRect.x + playerRect.w / 2f - p.projectileRect.w / 2f;
        p.projectileRect.y = playerRect.y + playerRect.h / 2f - p.projectileRect.h / 2f;
        
        p.active = true;
        projectiles.Add(p);
    }

    public void Attack(Engine engine)
    {
        if (strength < melee.strengthCost)
            return;

        float mouseX = 0f;
        float mouseY = 0f;
        SDL_GetMouseState(&mouseX, &mouseY);
        float dx = mouseX - (playerRect.x + playerRect.w / 2f);
        float dy = mouseY - (playerRect.y + playerRect.h / 2f);
        float length = Math.Sqrt(dx * dx + dy * dy);
        if (length > 0)
        {
            dx /= length;
            dy /= length;
        }
        
        if (melee.meleeState == .Ready){
            strength -= melee.strengthCost;
        }
        
        melee.Attack(playerRect, dx, dy);
    }

    public void Shutdown()
    {
        if (playerTexture != null)
            SDL_DestroyTexture(playerTexture);
        melee.Shutdown();
    }

    public void CycleProjectile()
    {
        if (currentProjectile == .Normal) currentProjectile = .Fast;
        else if (currentProjectile == .Fast) currentProjectile = .Heavy;
        else currentProjectile = .Normal;
    }

    public void CycleMelee()
    {
        if (currentMelee == .Sword) currentMelee = .Dagger;
        else if (currentMelee == .Dagger) currentMelee = .Mace;
        else currentMelee = .Sword;
        melee.Equip(currentMelee);
    }
}