import sys
import os
import regex


CUR_DIR = os.path.dirname(os.path.abspath(__file__))


#get the input arguments

def get_input_args():
    if len(sys.argv) < 3:
        print("Usage: python create_testbench.py <testbench_name> <wrapper_name> ")
        sys.exit(1)

    testbench_name = sys.argv[1]
    wrapper_name = sys.argv[2]
    return testbench_name, wrapper_name


def remove_module_definitions(testbench_file,wrapper_name):
    pattern_to_remove = regex.compile(rf'\bmodule\s+{wrapper_name}\b.*?endmodule', regex.DOTALL)
    with open(testbench_file, 'r') as file:
        content = file.read()
        content = pattern_to_remove.sub('', content)
    with open(testbench_file, 'w') as file:
        file.write(content)

def add_wrapper_module_definition(testbench_file, wrapper_name):
    helper_pkg= os.path.join(CUR_DIR, "aes_helper_pkg.sv") 
    pattern_to_add = regex.compile(rf'\bmodule\s+{wrapper_name}+_wrapper\b.*?endmodule', regex.DOTALL)
    with open(helper_pkg, 'r') as file: 
        content = file.read()
        
        full_match = pattern_to_add.search(content)
        if full_match:
            wrapper_content = full_match.group(0)
            with open(testbench_file, 'a') as tb_file:
                tb_file.write("\n\n" + wrapper_content + "\n")
            print(f"Added {wrapper_name}_wrapper module definition to {testbench_file}.")
        else:
            print(f"Warning: No match found for {wrapper_name}_wrapper in {helper_pkg}")
            sys.exit(1)


def subsitute_wrapper_name(testbench_file, wrapper_name):
    with open(testbench_file, 'r') as file:
        content = file.read()
        # subsitute the content all instances of match "wrapper_name" with "wrapper_name_wrapper"
        content = regex.sub(rf'\b{wrapper_name}\b', f'{wrapper_name}_wrapper', content)
            
    with open(testbench_file, 'w') as file:
        file.write(content)

def main():
    testbench_name, wrapper_name = get_input_args()
    
    # Define the path to the testbench file
    testbench_file = os.path.join(CUR_DIR, f"{testbench_name}.anvil.sv")
    
    # Check if the testbench file exists
    if not os.path.exists(testbench_file):
        print(f"Error: Testbench file {testbench_file} does not exist.")
        sys.exit(1)

    # Remove module definitions for the wrapper name
    remove_module_definitions(testbench_file, wrapper_name)

    # substitute the wrapper name in the testbench file
    subsitute_wrapper_name(testbench_file, wrapper_name)

    # Add the wrapper module definition at the end of the testbench file
    add_wrapper_module_definition(testbench_file, wrapper_name)

    print(f"Testbench {testbench_name} has been successfully updated with wrapper {wrapper_name}.")


if __name__ == "__main__":
    main()
