namespace Manivela_Engine;

using SDL3;

interface IGame
{
    public float WorldWidth { get; set; }
    public float WorldHeight { get; set; }
    void Init(Engine engine);
    void Update(Engine engine, float delta);
    void Draw(Engine engine);
    void Shutdown();
    void OnEvent(Engine engine, SDL_Event ev);
}
