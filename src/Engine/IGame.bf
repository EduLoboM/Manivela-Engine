namespace Manivela_Engine;

using SDL3;

interface IGame
{
    void Init(Engine engine);
    void Update(Engine engine, float delta);
    void Draw(Engine engine);
    void Shutdown();
    void OnEvent(Engine engine, SDL_Event ev);
}
