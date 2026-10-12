/// The decimal numbers in a fixture line, in order.
List<double> numbersIn(String text) =>
    RegExp(r'-?\d+\.\d+')
        .allMatches(text)
        .map((match) => double.parse(match.group(0)!))
        .toList();
