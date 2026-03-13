using System;
using SDL3;

namespace Manivela_Engine;

class Engine
{
    public SDL_Window* Window;
    public SDL_Renderer* Renderer;
    public bool IsRunning = true;
    public bool* KeyboardState;
    public int32 windowMode = 0;

    public int Init(String windowName)
    {
        if (!SDL_Init(.SDL_INIT_VIDEO)) return 1;
        
        Window = SDL_CreateWindow(windowName, 1920, 1080, .SDL_WINDOW_RESIZABLE | .SDL_WINDOW_MAXIMIZED);
        if (Window == null) return 2;

        Renderer = SDL_CreateRenderer(Window, null);
        if (Renderer == null) return 3;

        SDL_SetRenderLogicalPresentation(Renderer, 1920, 1080, .SDL_LOGICAL_PRESENTATION_STRETCH);

        KeyboardState = SDL_GetKeyboardState(null);
        return 0;
    }

public void Run(IGame game)
    {
        game.Init(this);
        var PreviousTime = SDL_GetPerformanceCounter();
        var Frequency = SDL_GetPerformanceFrequency();
        
        double fixedDelta = 1.0 / 60.0;
        double accumulator = 0.0;

        double[] snapFrequencies = scope double[] ( 1.0/30.0, 1.0/60.0, 1.0/120.0, 1.0/144.0, 1.0/240.0 );

        while (IsRunning)
        {
            SDL_Event ev = .();
            while (SDL_PollEvent(&ev))
            {
                if (ev.type == (.)SDL_EventType.SDL_EVENT_QUIT)
                    IsRunning = false;
                
                if (ev.type == (.)SDL_EventType.SDL_EVENT_KEY_DOWN && ev.key.repeat == false)
                {
                    if (ev.key.scancode == (.)SDL_Scancode.SDL_SCANCODE_F11)
                    {
                        windowMode = (windowMode + 1) % 3;
                        if (windowMode == 0)
                        {
                            SDL_SetWindowFullscreen(Window, false);
                            SDL_SetWindowBordered(Window, true);
                        }
                        else if (windowMode == 1)
                        {
                            SDL_SetWindowFullscreen(Window, false);
                            SDL_SetWindowBordered(Window, false);
                            SDL_MaximizeWindow(Window);
                        }
                        else if (windowMode == 2)
                        {
                            SDL_SetWindowFullscreen(Window, true);
                        }
                    }
                }

                game.OnEvent(this, ev);
            }

            var CurrentTime = SDL_GetPerformanceCounter();
            double delta = (CurrentTime - PreviousTime) / (double)Frequency;
            PreviousTime = CurrentTime;

            for (double freq in snapFrequencies)
            {
                if (Math.Abs(delta - freq) < 0.0002)
                {
                    delta = freq;
                    break;
                }
            }

            if (delta > 0.25)
                delta = 0.25;

            accumulator += delta;

            KeyboardState = SDL_GetKeyboardState(null);

            while (accumulator >= fixedDelta)
            {
                game.Update(this, (float)fixedDelta);
                accumulator -= fixedDelta;
            }

            SDL_SetRenderDrawColor(Renderer, 255, 255, 255, 255);
            SDL_RenderClear(Renderer);
            
            game.Draw(this);
            
            SDL_RenderPresent(Renderer);
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
