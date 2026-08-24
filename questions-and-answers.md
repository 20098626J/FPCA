# Quiz Bank: Questions, Answers and Feedback

39 questions across 4 categories.

**Categories:** Arrays/Primitive_and_Object_Arrays, Methods and Driver, Introduction, Loops

---

## 1. Q1. Why arrays

*Category: Arrays/Primitive_and_Object_Arrays*

Why are arrays used in programming?

**Answers**

- [ ] To store a single value of any type
  - *Arrays store multiple values, not just one.*
- [x] To store many values of the same type efficiently
  - *This is correct.*
- [ ] To store only numbers in sequential order
  - *Arrays can hold many data types, not only numbers.*
- [ ] To replace all loops in code
  - *Loops often work together with arrays; arrays do not replace loops.*

## 2. Q2. Reusing n in loop

*Category: Arrays/Primitive_and_Object_Arrays*

What happens when you read a number into the same variable n repeatedly in a loop?

**Answers**

- [ ] Each number is stored permanently
  - *A single variable holds only one value at a time.*
- [x] The previous number is overwritten
  - *This is correct.*
- [ ] The numbers are all added automatically
  - *Only if you add them to a sum explicitly.*
- [ ] A syntax error occurs
  - *This is valid Java syntax.*

## 3. Q3. Declare int[10]

*Category: Arrays/Primitive_and_Object_Arrays*

In Java, how do you declare an array of 10 integers?

**Answers**

- [ ] int numbers = new int(10);
  - *Parentheses are not used for array creation.*
- [x] int numbers[] = new int[10];
  - *This is correct.*
- [ ] numbers = new int[10];
  - *Missing the type in the declaration.*
- [ ] int numbers = [10];
  - *Invalid Java syntax.*

## 4. Q4. Default int value

*Category: Arrays/Primitive_and_Object_Arrays*

What is the default value for elements in a new int array?

**Answers**

- [ ] 1
  - *Default is not 1.*
- [ ] null
  - *Only object references default to null.*
- [x] 0
  - *This is correct.*
- [ ] undefined
  - *Java assigns defined default values.*

## 5. Q5. Access elements

*Category: Arrays/Primitive_and_Object_Arrays*

How are array elements accessed in Java?

**Answers**

- [ ] Using the get() method
  - *Java arrays do not have a get() method.*
- [x] By index starting at 0
  - *This is correct.*
- [ ] By key names
  - *That applies to maps, not arrays.*
- [ ] Randomly
  - *Elements are accessed by index positions.*

## 6. Q6. Print numbers[2]

*Category: Arrays/Primitive_and_Object_Arrays*

What will System.out.println(numbers[2]) print if numbers[2] has been set to 18?

**Answers**

- [ ] 0
  - *0 would be the default before assignment.*
- [ ] 2
  - *2 is the index, not the value.*
- [x] 18
  - *This is correct.*
- [ ] null
  - *Only object arrays can contain null references.*

## 7. Q7. length meaning

*Category: Arrays/Primitive_and_Object_Arrays*

What does numbers.length return?

**Answers**

- [ ] The last index used
  - *The last index is length - 1.*
- [x] The total capacity of the array
  - *This is correct.*
- [ ] The number of elements currently populated
  - *Java does not track the populated count separately.*
- [ ] The sum of all elements
  - *You must compute sums explicitly.*

## 8. Q8. Rule for input data

*Category: Arrays/Primitive_and_Object_Arrays*

What is the main rule when dealing with input data, as described in the slides?

**Answers**

- [ ] Never store input data
  - *You generally want to keep inputs for later use.*
- [ ] Always lose old input
  - *We aim not to lose inputs.*
- [x] Never lose input data
  - *This is correct.*
- [ ] Avoid loops with input
  - *Loops are typically used to process input and arrays.*

## 9. Q9. String[] declaration

*Category: Arrays/Primitive_and_Object_Arrays*

Which of the following is a valid declaration for an array of String objects?

**Answers**

- [ ] String words = new String(4);
  - *Invalid: missing array brackets and uses parentheses.*
- [ ] String[] words = new String[4];
  - *Valid declaration.*
- [ ] String words[] = {"Dog", "Cat"};
  - *Valid initialization with literals.*
- [x] Both B and C
  - *This is correct.*

## 10. Q10. Out-of-range access

*Category: Arrays/Primitive_and_Object_Arrays*

What happens if an array index outside its range is accessed?

**Answers**

- [ ] Java assigns a default value
  - *No default assignment beyond bounds.*
- [ ] Java ignores the statement
  - *An exception is thrown.*
- [x] Java throws an ArrayIndexOutOfBoundsException
  - *This is correct.*
- [ ] The program exits successfully
  - *The exception interrupts normal flow.*

## 11. Q11. Print all elements

*Category: Arrays/Primitive_and_Object_Arrays*

How do you print all elements of an array named words?

**Answers**

- [ ] System.out.println(words);
  - *Prints the reference, not the contents.*
- [x] for (int i = 0; i < words.length; i++) { System.out.println(words[i]); }
  - *This is correct.*
- [ ] System.out.println(words[i]);
  - *Missing the loop.*
- [ ] print(words.all());
  - *Invalid Java code.*

## 12. Q12. Types storable

*Category: Arrays/Primitive_and_Object_Arrays*

What kind of data can arrays in Java store?

**Answers**

- [ ] Only primitive data types
  - *Arrays can also store objects.*
- [ ] Only objects
  - *Arrays can also store primitives.*
- [x] Both primitive types and objects
  - *This is correct.*
- [ ] Only Strings
  - *Strings are just one kind of object.*

## 13. Q13. Default in Person[]

*Category: Arrays/Primitive_and_Object_Arrays*

In an array Person[] friends = new Person[4], what does each element initially contain?

**Answers**

- [ ] A new Person object
  - *Objects are not automatically constructed.*
- [ ] A random value
  - *Java uses well-defined defaults.*
- [x] null
  - *This is correct.*
- [ ] Empty
  - *There is no special Empty value in Java.*

## 14. Q14. Average on partial array

*Category: Arrays/Primitive_and_Object_Arrays*

If an array results has 15 elements but only 12 are used, how should you calculate the average?

**Answers**

- [ ] Divide by 15
  - *This would give an incorrect average.*
- [x] Divide by 12
  - *This is correct.*
- [ ] Divide by results.length()
  - *length gives capacity, not usage.*
- [ ] Java automatically adjusts
  - *Java does not track number of used elements.*

## 15. Q15. Method call on element

*Category: Arrays/Primitive_and_Object_Arrays*

In a Person array, what does friends[i].printFirstName() do?

**Answers**

- [ ] Creates a new Person
  - *No object construction occurs here.*
- [x] Calls a method on the Person object stored at index i
  - *This is correct.*
- [ ] Accesses an element without printing anything
  - *The method name indicates it prints.*
- [ ] Causes a compile error
  - *Valid if the method exists and the element is non-null.*

## 16. Q1: void keyword

*Category: Methods and Driver*

What keyword in Java defines a method that returns nothing?

**Answers**

- [ ] empty
  - *Incorrect – empty is not a Java keyword; it describes strings or collections.*
- [ ] none
  - *Incorrect – none is not valid Java syntax.*
- [x] void
  - *Correct – void specifies that no value is returned.*
- [ ] null
  - *Incorrect – null means no object reference, not a return type.*

## 17. Q2: return type

*Category: Methods and Driver*

Which part of a method defines the data type returned?

**Answers**

- [ ] Parameter list
  - *Incorrect – defines inputs, not outputs.*
- [x] Return type
  - *Correct – declares the kind of data the method returns.*
- [ ] Method name
  - *Incorrect – identifies the method but not its return data.*
- [ ] Body
  - *Incorrect – contains the code, not the return type.*

## 18. Q3: method header order

*Category: Methods and Driver*

What is the correct order for a method header?

**Answers**

- [ ] Return type → parameter list → method name
  - *Incorrect – the name follows the return type.*
- [ ] Parameter list → return type → method name
  - *Incorrect – parameters go last.*
- [x] Return type → method name → parameter list
  - *Correct – that’s the Java method signature order.*
- [ ] Method name → return type → parameter list
  - *Incorrect – the return type must appear before the method name.*

## 19. Q4: return keyword

*Category: Methods and Driver*

Which keyword is used to send a value back from a method?

**Answers**

- [ ] break
  - *Incorrect – break exits a loop or switch, not a method.*
- [ ] yield
  - *Incorrect – yield is used in switch expressions (Java 14+).*
- [ ] continue
  - *Incorrect – continue skips to the next loop iteration.*
- [x] return
  - *Correct – return sends data back to the caller.*

## 20. Q5: purpose of methods

*Category: Methods and Driver*

What is the main purpose of using methods?

**Answers**

- [ ] To make code run faster
  - *Incorrect – performance is not the main goal of methods.*
- [ ] To reduce memory usage
  - *Incorrect – methods do not directly control memory allocation.*
- [ ] To increase lines of code
  - *Incorrect – methods reduce repetition and simplify programs.*
- [x] To reuse code and improve structure
  - *Correct – methods encourage modular, reusable design.*

## 21. Q6: naming convention

*Category: Methods and Driver*

What is the method name style convention in Java?

**Answers**

- [ ] ALL_CAPS
  - *Incorrect – used for constants, not methods.*
- [ ] snake_case
  - *Incorrect – used in Python, not Java.*
- [x] camelCase with verbs
  - *Correct – Java methods use camelCase verbs like printResult().*
- [ ] PascalCase
  - *Incorrect – reserved for class names, not methods.*

## 22. Q7: parameters

*Category: Methods and Driver*

Which part of a method lists inputs it can receive?

**Answers**

- [x] Parameter list
  - *Correct – the parameter list defines inputs.*
- [ ] Body
  - *Incorrect – contains statements, not parameters.*
- [ ] Return type
  - *Incorrect – defines the type of data returned, not inputs.*
- [ ] Signature
  - *Incorrect – includes the parameter list but is not itself a list of inputs.*

## 23. Q8: driver contains

*Category: Methods and Driver*

What must a Driver class contain?

**Answers**

- [ ] Only static methods
  - *Incorrect – driver may also contain instance methods.*
- [ ] A Scanner object
  - *Incorrect – a Scanner is optional.*
- [x] A main() method
  - *Correct – every Java program begins execution in main().*
- [ ] An import statement
  - *Incorrect – not required unless external packages are used.*

## 24. Q9: driver purpose

*Category: Methods and Driver*

What is the purpose of the Driver class?

**Answers**

- [x] To run and test other classes
  - *Correct – the driver runs and coordinates the program.*
- [ ] To hold all method definitions
  - *Incorrect – functionality belongs in other classes.*
- [ ] To compile code
  - *Incorrect – the compiler handles compilation.*
- [ ] To store constants
  - *Incorrect – constants belong in a separate utility class.*

## 25. Q10: object creation

*Category: Methods and Driver*

What statement creates an object from a class?

**Answers**

- [ ] Calculator() = new calc;
  - *Incorrect – invalid Java syntax.*
- [x] Calculator calc = new Calculator();
  - *Correct – this is the standard syntax for object creation.*
- [ ] new Calculator = calc();
  - *Incorrect – assignment and constructor order are reversed.*
- [ ] calc.Calculator();
  - *Incorrect – constructors are not called on existing objects.*

## 26. Q11: main method meaning

*Category: Methods and Driver*

In Java, what does 'public static void main' mean?

**Answers**

- [ ] A loop statement
  - *Incorrect – main() is not a loop.*
- [x] Starting point of the program
  - *Correct – main() marks where execution begins.*
- [ ] A method returning true/false
  - *Incorrect – main() returns nothing.*
- [ ] A variable declaration
  - *Incorrect – it defines a method, not a variable.*

## 27. Q12: non-static call

*Category: Methods and Driver*

Which method type requires an object to call it?

**Answers**

- [ ] Main method
  - *Incorrect – special entry method that is static.*
- [ ] Private method
  - *Incorrect – access modifier doesn’t dictate object requirement.*
- [x] Non-static method
  - *Correct – these require an object instance to invoke.*
- [ ] Static method
  - *Incorrect – static methods can be called on the class directly.*

## 28. Q13: return number

*Category: Methods and Driver*

What will 'return number * 2;' do?

**Answers**

- [ ] Print double the number
  - *Incorrect – return doesn’t print anything.*
- [ ] Multiply twice and stop
  - *Incorrect – multiplication happens once; the statement returns the result.*
- [ ] Store result in a variable
  - *Incorrect – it only returns a value to the caller.*
- [x] Send back twice the number
  - *Correct – returns double the input value.*

## 29. Q14: boolean return type

*Category: Methods and Driver*

What data type should a method use to return true or false?

**Answers**

- [ ] char
  - *Incorrect – stores characters, not logical results.*
- [ ] int
  - *Incorrect – integers can’t directly represent true/false.*
- [ ] String
  - *Incorrect – holds text, not logical values.*
- [x] boolean
  - *Correct – boolean stores true or false values.*

## 30. Q15: boolean naming

*Category: Methods and Driver*

Which is a valid Boolean method name?

**Answers**

- [ ] booleanCheck
  - *Incorrect – naming does not follow Java style.*
- [x] isEven
  - *Correct – Boolean methods often start with is, has, or can.*
- [ ] doEven
  - *Incorrect – implies an action, not a check.*
- [ ] checkNumber
  - *Incorrect – does not follow the Boolean naming convention.*

## 31. Q16: overloading truth

*Category: Methods and Driver*

Which statement about overloading is TRUE?

**Answers**

- [x] Same method name, different parameter list
  - *Correct – overloading requires different parameters.*
- [ ] Different method name, same parameters
  - *Incorrect – that is not overloading.*
- [ ] Same method body reused
  - *Incorrect – overloading involves separate methods.*
- [ ] Same name, different return type only
  - *Incorrect – Java does not allow overloading by return type alone.*

## 32. Q17: overloading pair

*Category: Methods and Driver*

Which of these pairs correctly shows overloading?

**Answers**

- [x] addNum(int, int) and addNum(double, double)
  - *Correct – same name, different parameter types.*
- [ ] addNum(int) and addNum(int)
  - *Incorrect – identical signatures are not overloaded.*
- [ ] addNum() and addNum()
  - *Incorrect – identical signatures are not overloaded.*
- [ ] addNum() and addNumSame()
  - *Incorrect – different names, not overloaded.*

## 33. Q18: boolean return

*Category: Methods and Driver*

What does a Boolean method return?

**Answers**

- [ ] 1 or 0
  - *Incorrect – numeric, not Boolean values.*
- [x] true or false
  - *Correct – boolean methods return logical true/false values.*
- [ ] Boolean object
  - *Incorrect – primitive boolean returns true/false, not an object.*
- [ ] Yes or No
  - *Incorrect – text strings, not Boolean literals.*

## 34. Q19: static before main

*Category: Methods and Driver*

What keyword must appear before main() in a Driver class?

**Answers**

- [x] static
  - *Correct – static allows main() to run without an instance.*
- [ ] this
  - *Incorrect – refers to current object, not class-level context.*
- [ ] return
  - *Incorrect – return cannot precede a method declaration.*
- [ ] void
  - *Incorrect – indicates no return value, but not required first.*

## 35. Q20: valid header

*Category: Methods and Driver*

Which Java method header is valid?

**Answers**

- [ ] public add(int a, int b)
  - *Incorrect – missing return type before method name.*
- [ ] int add(a int, b int)
  - *Incorrect – parameter declarations are invalid.*
- [x] public int add(int a, int b)
  - *Correct – includes access modifier, return type, name, and parameters.*
- [ ] method add(int, int)
  - *Incorrect – method is not a Java keyword.*

## 36. Q1. Compiling Java

*Category: Introduction*

What does the Java compiler produce from a .java file?

**Answers**

- [x] A .class file containing bytecode
  - *Correct.*
- [ ] A .exe file that the operating system runs directly
  - *Java does not compile straight to a native executable.*
- [ ] Nothing, because Java is never compiled
  - *Java is compiled before it is run.*

**Feedback:** Source code is compiled to bytecode, which the JVM then runs.

## 37. Q2. Main method

*Category: Introduction*

Where does a Java program begin running?

**Answers**

- [x] At the main method
  - *Correct.*
- [ ] At the first method in the file
  - *Position in the file makes no difference.*
- [ ] At the constructor of the first class
  - *A constructor only runs when an object is created.*

## 38. Q3. Counting loop

*Category: Loops*

How many times does for (int i = 0; i < 5; i++) run its body?

**Answers**

- [x] 5
  - *Correct, i takes the values 0 to 4.*
- [ ] 4
  - *The loop starts at 0, so there are 5 iterations.*
- [ ] 6
  - *The loop stops before i reaches 5.*

## 39. Q4. While versus do while

*Category: Loops*

What is the difference between a while loop and a do while loop?

**Answers**

- [x] A do while loop always runs its body at least once
  - *Correct, the condition is tested after the body.*
- [ ] A while loop always runs its body at least once
  - *A while loop tests its condition first, so the body may never run.*
- [ ] There is no difference between them
  - *They differ in when the condition is tested.*

