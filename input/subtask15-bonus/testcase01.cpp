// Calculate Pi using the Nilakantha series
double calculate_pi(int terms) {
    double pi = (double)3;    // Start with the first term of the series
    double two = (double)2;   // Cached value
    double four = (double)4;  // Cached value
    double one = (double)1;   // Cached value
    bool add = true;          // Control addition or subtraction

    for (int k = 1; k < terms; k++) {
        double i = (two * (double)k * (two * (double)k + one) * (two * (double)k + two));
        double term = four / i;
        if (add) {
            pi += term;
            add = false;
        } else {
            pi -= term;
            add = true;
        }
    }

    return pi;
}

int main(string argv[]) {
    int terms = 1000;  // Number of terms to sum
    double pi = calculate_pi(terms);
    cout << "Approximation of Pi after " << terms << " terms: " << pi << endl;
    return 0;
}