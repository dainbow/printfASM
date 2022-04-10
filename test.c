extern void Printf(const char* string, ...);

int main() {
    Printf("I %s %x %d%%%c%b\n", "love", 3802, 100, 33, 255);
}
