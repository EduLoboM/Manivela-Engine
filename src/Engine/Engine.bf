using System;
using SDL3;

namespace Manivela_Engine;

class Engine
{
    public SDL_Window* Window;
    public SDL_Renderer* Renderer;
    public bool IsRunning = true;
    public bool* KeyboardState;

    public int Init(String windowName)
    {
        if (!SDL_Init(.SDL_INIT_VIDEO)) return 1;
        
        Window = SDL_CreateWindow(windowName, 1780, 1000, .SDL_WINDOW_RESIZABLE);
        if (Window == null) return 2;

        Renderer = SDL_CreateRenderer(Window, null);
        if (Renderer == null) return 3;

        KeyboardState = SDL_GetKeyboardState(null);
        return 0;
    }

    public void Run(IGame game)
    {
        game.Init(this);

        var PreviousTime = SDL_GetPerformanceCounter();
        var Frequency = SDL_GetPerformanceFrequency();

        while (IsRunning)
        {
            SDL_Event ev = .();
            while (SDL_PollEvent(&ev))
            {
                if (ev.type == (.)SDL_EventType.SDL_EVENT_QUIT)
                    IsRunning = false;
                game.OnEvent(this, ev);
            }

            var CurrentTime = SDL_GetPerformanceCounter();
            float delta = (CurrentTime - PreviousTime) / (float)Frequency;
            PreviousTime = CurrentTime;

            KeyboardState = SDL_GetKeyboardState(null);

            game.Update(this, delta);

            SDL_SetRenderDrawColor(Renderer, 255, 255, 255, 255);
            SDL_RenderClear(Renderer);
            
            game.Draw(this);
            
            SDL_RenderPresent(Renderer);
            SDL_Delay(16);
        }

        game.Shutdown();
    }

    public ~this()
    {
        if (Renderer != null) SDL_DestroyRenderer(Renderer);
        if (Window != null) SDL_DestroyWindow(Window);
        SDL_Quit();
    }
}
