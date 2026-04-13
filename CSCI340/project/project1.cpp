#include <errno.h>      // used by strtol
#include <stdio.h>      // not sure I need this, if I use the write() system call.
#include <fcntl.h>      // TODO check if I need this.
#include <limits.h>     // defines the INT_MIN and INT_MAX macro.
#include <string.h>     // defines the strlen() function.
#include <unistd.h>     // defines system calls, such as read(), write(), open(), fork()
#include <stdlib.h>     // TODO check if I can remove this.
#include <pthread.h>   // the... non-system call way to create threads.
#include <sys/wait.h>
#include <sys/types.h>  // defines the 'pid_t' data type.

int collect_args(int argc, char* argv[], int*& args);
void child_handler(int* read_pipe, int* write_pipe, int fileFD);
void parent_handler(int* read_pipe, int* write_pipe, int argc, char* argv[], int fileFD);
void* sum(void* args);

// structs (classes too) require the definition before I instantiate it. 
struct thread_args{
  int lower_bound;
  int upper_bound;
  int partial_sum;
  int id;
  int fileFD;
};

int main(int argc, char** argv){

  // Making sure I can use write() correctly.
  char greeting[] = "안녕하세요\n";

  int fileFD = open("Cardoso_15132824.txt", O_CREAT | O_APPEND | O_WRONLY, 0744);
  if(fileFD == -1){
    const char* s = "Error opening output file\n";
    write(2, s, strlen(s));
  }

  // 1 is the fd for whatever stdout points to. 
  write(1, greeting, strlen(greeting)); 

  // Make sure there are arguments to parse.
  bool isEven = ((argc - 1) % 2) == 0;
  if(argc <= 1 || !isEven){
    char buffer[] = "Usage: ./Cardoso_15132824 <num1> <num2> [<num1> <num2>]...\n";
    write(2, buffer, strlen(buffer));   
    return 1;
  }
  
  // the file descriptors for the parent and child pipes.
  int to_child[2]; // pipes have two fds. index 0 for the read end, index 1 for the write end.
  int to_parent[2];
  
  // create the pipes.
  int flag1 = pipe(to_child);
  int flag2 = pipe(to_parent);

  // pipe() returns a 0 on success.
  // check for failure.
  if(flag1 != 0 or flag2 != 0){

    // I did not know that a string literal is a CONST char*.
    // today I learned...
    const char* s = "Error while creating parent or child pipe\n";
    write(2, s, strlen(s));
    return 1;
  }

  // print message to outfile.
  char buffer[512] = "Parent: pipes created.\n";
  int length = strlen(buffer);
  write(fileFD, buffer, length);

  // fork() returns a pid_t data type, defined in <sys.types.h>
  // often usable if you import <unistd.h>. 
  pid_t process_ID;

  /*
   * From this point point, two processes exist.
   * That is, the OS makes a copy of the original process and, conceptually, this copy is the child process.
   * The original(parent) and child process contain their own copies of all stack and heap variables.
   */  
  process_ID = fork();
  
  if(process_ID == -1){
    const char* s = "Error while creating fork. Exiting program.\n";
    write(2, s, strlen(s));
    return 1;
  }else if(process_ID == 0){ // we're the child process
    length = snprintf(buffer, sizeof(buffer), "Child: after fork().\n");
    write(fileFD, buffer, length);
    child_handler(to_child, to_parent, fileFD);
  }else if(process_ID > 0){ // we're the parent process.

    // print message to outfile.
    length = snprintf(buffer, sizeof(buffer), "Parent: child process forked with child process id = %d\n", (int)process_ID);
    write(fileFD, buffer, length);
  
    parent_handler(to_parent, to_child, argc, argv, fileFD);
  }
  
  return 0;
}

/*
 *  Parses command line arguments
 *    creates a heap allocated int array and stores it in the third argument.
 *    returns the number of valid arguments 
 */

int collect_args(int argc, char* argv[], int*& args){

  // collect the number of int arguments passed to the command line.
  int valid_args = 0;
  args = new int[argc-1]();

  // loop over all arguments passed to the command line.
  for(int i = 1; i < argc; i++){
    
    bool foundNumber = false;
    int n = 0;
   
    for(char* p = argv[i]; *p != '\0'; p++){
  
      // whenever I find a number 'char'
      char c = *p;
      if(c >= '0' && c <= '9'){
        // start accumulating the string representation as an int.
        n = n*10 + (c - '0');
        foundNumber = true;
      }else if(foundNumber){ // stop reading from the string after encountering a non-number 'char'. i.e. stop at a in '123abc'.
        // actually, for now just assume I can read at most one number per command line arg
        break;
      }
    }
    
    // store the number, if any was found.
    if(foundNumber){
      args[valid_args++] = n;
    }
  }

  // WARNING
  //  Even though the number of arguments is guaranteed to be even
  //  The number of integers actually parsed could be odd.
  //  I need to figure out how I want the program to behave with edge cases like
  //  ./progName 1 100 apple 101 
  //  ./progName 1 100 apple101banana 200
  //  ./progName 1 100 apple101banana150 200
  return valid_args;

  /*
   *  Took parts of this code from:
   *    https://en.cppreference.com/w/c/string/byte/strtol.html 
   */
  /*
  for(int i = 1; i < argc; i++){
    errno = 0; // per the docs, this is set to ERANGE on error.
    char* end;
    const long n = strtol(argv[i], &end, 10);

    // wonder what ERANGE is supposed to be.
    // Looks like a macro.
    const bool range_error = errno == ERANGE;
    if(range_error || end[0] != '\0'){
      char buffer[512];
      snprintf(buffer, 512, "Error parsing argv[%d].\n\tUnprocessed string: %s\n", i, end);
      write(2, buffer, strlen(buffer)); // writing to the stderror using system calls :)
      continue; // ignore the cmd argument. 
    }else if(n < INT_MIN || n > INT_MAX){ // check if I cannot convert to an integer.
      char s[] = "Given argument is too big or too smal for an int\n"; // creating strings in different ways, as practice.
      write(2, s, strlen(s));
      continue; // ignore the cmd argument.
    }else{ // Success!
      args[i-1] = (int)n;
      valid_args++;
    }
  }
  return valid_args;
  */
  
}

// I call this with (to_child, to_parent) in main().
void child_handler(int* read_pipe, int* write_pipe, int fileFD){

  // closing the ends I don't need. 
  close(read_pipe[1]);
  close(write_pipe[0]);    

  // declare some variables.
  int length;
  int* args;
  int accumulator;
  int attr_flag; // checks if p_thread_attr_init() was sucessful
  int buffLength;
  char buffer[512];
  pthread_attr_t attr; // attribute data type for a pthread.
  pthread_t* threads; // stores an array of pthread_t
  thread_args* targs; // array of arguments to each thread. 

  // read() blocks in the child if the parent hasn't written to the pipe object yet.
  // That is, it goes to sleep and wakes up once it can pull bytes from the pipe object.
  // expect the length of the array first.
  read(read_pipe[0], &length, sizeof(int));

  // create an int array of size length.
  args = new int[length];

  // expect the actual array afterwards.
  read(read_pipe[0], args, length * sizeof(int));
  
  // print another message.
  buffLength = snprintf(buffer, sizeof(buffer), "Child: consumed lower and upper bound pairs from pipe 'to_child': ");
  for(int i = 0; i < length / 2; i++){
    buffLength += snprintf(buffer + buffLength, sizeof(buffer) - buffLength, "(%d, %d) ", args[i*2], args[i*2 + 1]);
  }
  buffer[buffLength++] = '\n';
  buffer[buffLength] = '\0';
  write(fileFD, buffer, buffLength);
  

  // initialize a thread attribute object
  // this contains meta data on the attributes I initialize my thread with.
  attr_flag = pthread_attr_init(&attr);

  // check if the attr_object failed to initialize.
  if(attr_flag){
    const char* s = "Unable to initialize thread attribute object.\n";
    write(2, s, strlen(s));
  } 
  
  threads = new pthread_t[length/2]; // allocate memory for the threads.
  targs = new thread_args[length/2]; // allocate memory for thread arguments.

  // create the threads.
  for(int i = 0, pairs = length / 2; i <  pairs; i++){

    // [10,20,30,40,50] example 'args' array.
    int lower_bound = args[i*2 + 0];
    int upper_bound = args[i*2 + 1];
    targs[i] = {lower_bound, upper_bound, 0, i, fileFD}; // initialize each thread argument object.
    
    // create the thread, and store it in the 'threads' array.
    pthread_create(&threads[i], &attr, sum, &targs[i]);
  }

  // initialize accumulator.
  accumulator = 0;
  
  // reap threads.
  for(int i = 0, pairs = length / 2; i < pairs; i++){
    pthread_join(threads[i], nullptr); // waits until the thread finishes/dies.
    accumulator += targs[i].partial_sum; // it's now safe to read .partial_sum
  }
  
  // send the results back to the parent.
  write(write_pipe[1], &accumulator, sizeof(int));

  // print message.
  buffLength = snprintf(buffer, sizeof(buffer), "Child: produced into pipe 'to_parent'. The grand total sum produced = %d\n", accumulator);
  write(fileFD, buffer, buffLength);

  // print exit message
  buffLength = snprintf(buffer, sizeof(buffer), "Child: terminating with status = %d\n", 0);
  write(fileFD, buffer, buffLength);

  // cleanup
  delete[] args;
  delete[] targs;
  delete[] threads;
  pthread_attr_destroy(&attr);

  exit(0);
}

// I call this with (to_parent, to_child, ... ) in main().
void parent_handler(int* read_pipe, int* write_pipe, int argc, char** argv, int fileFD){

  // accumulate the command line arguments.
  int* args;
  int valid_args = collect_args(argc, argv, args);
  
  // concatenate the arguments in buffer.
  char buffer[512]  = "Parent: program started with command line arguments:";
  int length = strlen(buffer);
  for(int i = 0; i < valid_args; i++){
    length += snprintf((buffer+length), sizeof(buffer)-length, " %d", args[i]);
  }

  // add a new line.
  buffer[length++] = '\n';
  buffer[length] = '\0';
  
  // write to the output file.
  write(fileFD, buffer, strlen(buffer));
 
  // closing the ends I don't need. 
  close(read_pipe[1]);
  close(write_pipe[0]);

  // send the number of arguments, in the array, to the child.
  write(write_pipe[1], &valid_args, sizeof(int));

  // send the array and its size, in bytes, to the child.
  write(write_pipe[1], args, valid_args * sizeof(int));

  // print successful pipe write message to output.txt.
  length = snprintf(buffer, sizeof(buffer), "Parent: produced lower and upper bound pairs into pipe 'to_child': ");
  for(int i = 0, j = valid_args / 2; i < j; i++){
    length += snprintf(buffer + length, sizeof(buffer) - length, "(%d, %d) ", args[i*2], args[i*2 + 1]);
  }
  // make the string look nice :)
  buffer[length++] = '\n';
  buffer[length] = '\0';
  
  // print the pairs to the file.
  write(fileFD, buffer, length);

  // read the sum from the child.
  int sum;
  read(read_pipe[0], &sum, sizeof(int));
  
  // print the sum to the file.
  length = snprintf(buffer, sizeof(buffer), "Parent: consumed from pipe 'to_parent'. The grand total sum consumed = %d\n", sum);
  write(fileFD, buffer, length);

  // reap the child.
  int status;
  pid_t child_PID = wait(&status);
  length = snprintf(buffer, sizeof(buffer), "Parent: child terminated with return status = %d\n", status);
  write(fileFD, buffer, length);

  // 안녕히 가세요
  length = snprintf(buffer, sizeof(buffer), "Parent: program terminating. 안녕히 가세요!\n");
  write(fileFD, buffer, length);

  /*
   * Clean up.
   */
  delete[] args;
}

void * sum(void* arg){
  // type cast the generic pointer back to a thread_args object.
  thread_args* targ = (thread_args*) arg;
  
  // do the 'work'
  int lower_bound = targ->lower_bound;
  int upper_bound = targ->upper_bound;
  while(lower_bound <= upper_bound){
    targ->partial_sum += lower_bound;
    lower_bound++;
  }
  
  // printing message
  int length;
  char buffer[512];

  length = snprintf(buffer, sizeof(buffer), "Child Thread %d executed: %d, %d, %d\n", targ->id, targ->lower_bound, targ->upper_bound, targ->partial_sum);
  write(targ->fileFD, buffer, length);
  
  return nullptr;
}
