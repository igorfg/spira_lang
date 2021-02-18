int age;

int main() {
  writeln("Enter your age: ");
  read(age);

  if(age < 50){
    writeln("Sorry! Try again next year :(");
  } else {
    writeln("Congratulations! You finally did it!");
  }
  return 0;
}
