import sys
import os
import regex


CUR_DIR = os.path.dirname(os.path.abspath(__file__))


#get the input arguments

def get_input_args():
    if len(sys.argv) < 3:
        print("Usage: python create_testbench.py <testbench_name> <wrapper_name> --cleanup")
        sys.exit(1)

    testbench_name = sys.argv[1]
    wrapper_name = sys.argv[2]
    clean = True if len(sys.argv) > 3 and sys.argv[3] == "--cleanup" else False
    return testbench_name, wrapper_name, clean


def remove_module_definitions(testbench_file,wrapper_name):
    pattern_to_remove = regex.compile(rf'\bmodule\s+{wrapper_name}_0\b.*?endmodule', regex.DOTALL)
    with open(testbench_file, 'r') as file:
        content = file.read()
        content = pattern_to_remove.sub('', content)
    with open(testbench_file, 'w') as file:
        file.write(content)

def add_wrapper_module_definition(testbench_file, wrapper_name):
    helper_pkg= os.path.join(CUR_DIR, "axi_helper_pkg.sv") 
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

def get_testbench_top(testbench_file,testbench_name):
    with open(testbench_file, 'r') as file:
        content = file.read()
        pattern = rf'\bmodule\s+{testbench_name}\b.*?endmodule'
        match = regex.search(pattern, content, regex.DOTALL)
        if match:
            no_of_matches = len(regex.findall(pattern, content, regex.DOTALL))
            print(f"Found {no_of_matches} module definition for {testbench_name} in {testbench_file}.")
            return match.group(0)
        else:
            print(f"Error: No module definition found in {testbench_file}.")
            sys.exit(1)


def cleanup_testbench(testbench_file,testbench_top_content, wrapper_content):
    if not os.path.exists(testbench_file):
        print(f"Error: Testbench file {testbench_file} does not exist.")
        sys.exit(1)
        
    with open(testbench_file, 'w') as file:
        file.write('\n\n' + testbench_top_content + "\n\n")
    with open(testbench_file, 'a') as file:
        file.write('\n\n' + wrapper_content + "\n\n")

    print(f"Testbench {testbench_file} has been cleaned up.")
    

def subsitute_wrapper_name(testbench_file, wrapper_name):
    with open(testbench_file, 'r') as file:
        content = file.read()
        # subsitute the content all instances of match "wrapper_name" with "wrapper_name_wrapper"
        content = regex.sub(rf'\b{wrapper_name}_0\b', f'{wrapper_name}_wrapper', content)
            
    with open(testbench_file, 'w') as file:
        file.write(content)

def copy_file_to_src(testbench_name):
    src_dir = os.path.join(CUR_DIR, "../../axi/src")
    if not os.path.exists(src_dir):
        print(f"Error: Source directory {src_dir} does not exist.")
        sys.exit(1)
    print(f"Source directory: {src_dir}")
    testbench_new_path = os.path.join(src_dir, f"{testbench_name}.sv")
    testbench_file = os.path.join(CUR_DIR, f"{testbench_name}.anvil.sv")
    os.system(f"cp {testbench_file} {testbench_new_path}")

def main():
    testbench_name, wrapper_name, clean = get_input_args()

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

    if clean:
        testbench_top_content = get_testbench_top(testbench_file, testbench_name)
        wrapper_content = get_testbench_top("axi_helper_pkg.sv", f"{wrapper_name}_wrapper")
        cleanup_testbench(testbench_file, testbench_top_content, wrapper_content)

    else:
        add_wrapper_module_definition(testbench_file, wrapper_name)

    print(f"Testbench {testbench_name} has been successfully updated with wrapper {wrapper_name}.")
    copy_file_to_src(testbench_name)


if __name__ == "__main__":
    main()
