/// Szudzik's hash of 2 ints [wiki](https://en.wikipedia.org/wiki/Pairing_function)
int szdudzik(int x, int y) => x >= y ? x * x + x + y : x + y * y;
