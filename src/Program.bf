using System;

namespace Manivela_Engine;

class Program
{
    public static int Main(String[] args)
    {
        Console.WriteLine("Girando a Manivela...");

        Engine engine = scope .();
        int initResult = engine.Init("Manivela Engine");
        
        if (initResult != 0)
        {
            Console.WriteLine($"Manivela parou de girar. Erro Cód: {initResult}");
            return initResult;
        }

        EndswardRanch game = scope .();
        engine.Run(game);

        return 0;
    }
}