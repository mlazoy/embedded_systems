#include <stdlib.h>
#include <stdio.h>

extern size_t strlen(const char *c);
extern char *strcpy(char *char1, const char *char2);
extern char *strcat(char *char1, const char *char2);
extern int strcmp(const char *char1, const char *char2);

const char *s1 = "Hello world!42";
const char *s2 = "Hello world!";

int main() {
    size_t l1, l2;
    int eq;
    
    l1 = strlen(s1);
    l2 = strlen(s2);
    eq = strcmp(s1, s2);
    printf("Size of s1 = %zu, Size of s2 = %zu, cmp result = %d\n", l1, l2, eq);

    // Concatenate s1 to a dynamically allocated string
    char *s3 = malloc(strlen(s2) + strlen(s1) + 1);  // Allocate enough space
    if (s3 == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }
    strcpy(s3, s2); // Copy s2 into s3
    strcat(s3, s1); // Append s1 to s3
    printf("After concat: %s\n", s3);

    // Copy s2 into a new dynamically allocated string
    char *s4 = malloc(strlen(s2) + 1); // Allocate enough space for s2 + null terminator
    if (s4 == NULL) {
        printf("Memory allocation failed!\n");
        free(s3); // Don't forget to free previously allocated memory
        return 1;
    }
    strcpy(s4, s2); // Copy s2 into s4
    printf("After copy: %s\n", s4);

    // Free allocated memory
    free(s3);
    free(s4);

    return 0;
}
