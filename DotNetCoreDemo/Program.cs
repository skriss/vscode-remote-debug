using System;
using System.Threading;

namespace DotNetCoreDemo
{
    class Program
    {
        static void Main(string[] args)
        {
            while (true) {
                var env = Environment.GetEnvironmentVariables();

                Console.WriteLine("Hello world!");
                Thread.Sleep(5000);
            }
        }
    }
}
