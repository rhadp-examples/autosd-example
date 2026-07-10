#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char* argv[])
{
    std::string name = "AutoSD";
    if (argc > 1)
        name = argv[1];

    std::cout << "Hello from " << name << "!\n";
    return EXIT_SUCCESS;
}
