using System;
using SDL3;
using SDL3_image;
namespace Manivela_Engine;

class Projectile
{

    SDL_Texture* projectileTexture;
    public SDL_FRect projectileRect = .() { x = 400, y = 300, w = 20, h = 20 };
    public float speed = 1000f;
    public float damage = 10f;
    public float mass = 1f;
    public float dirX = 0f;
    public float dirY = 0f;
    public bool active = false;

    public void Update(float delta)
    {
        projectileRect.x += dirX * speed * delta;
        projectileRect.y += dirY * speed * delta;

        if (projectileRect.x < 0 || projectileRect.x > 1780 || projectileRect.y < 0 || projectileRect.y > 1000){
            active = false;
        }
        
    }

    public void Draw(Engine engine)
    {

    }

    public void Shutdown()
    {

    }
}
