import sys
import os


CUR_DIR = os.path.dirname(os.path.abspath(__file__))


def get_all_files_in_dir(directory):
    if not os.path.exists(directory):
        print(f"Error: Directory {directory} does not exist.")
        sys.exit(1)
        
    all_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(('.sv', '.svh')):
                all_files.append(os.path.abspath(os.path.join(root, file)))
    return all_files


def get_testbench_dependencies(RTL_DIR, flist):
    if not os.path.exists(RTL_DIR):
        print(f"Error: RTL directory {RTL_DIR} does not exist.")
        sys.exit(1)

    flist_path = os.path.join(RTL_DIR, flist)
    if not os.path.exists(flist_path):
        print(f"Error: File list {flist_path} does not exist.")
        sys.exit(1)
        
    with open(flist_path, 'r') as file:
        dependencies_list = file.readlines()
        
        inc_dirs = [line.split("+incdir+")[1].strip() for line in dependencies_list if line.startswith("+incdir+")]
        print(f"Found {len(inc_dirs)} include directories: {inc_dirs}")

        for dir in inc_dirs:
            all_files = get_all_files_in_dir(dir)
            dependencies_list.extend(all_files)

        dependencies_list += get_all_files_in_dir(RTL_DIR)
        cleaned_dependencies = [dep.strip() for dep in dependencies_list if dep.strip() and not dep.startswith("+incdir+")]
        return cleaned_dependencies
        


def preprocess_files(file):
    if not os.path.exists(file):
        print(f"Error: File {file} does not exist.")
        sys.exit(1)
    with open(file, 'r') as f:
        content = f.read()
        content = content.replace('`include', '// `include')
        return content

def create_synthesis_harness(dependencies_list):
    SYNTH_DIR = os.path.join(CUR_DIR, "synthesis")
    os.makedirs(SYNTH_DIR, exist_ok=True)
    os.makedirs(os.path.join(SYNTH_DIR, "rtl"), exist_ok=True)
    print(f"Synthesis directory created at: {SYNTH_DIR}")
    for dep in dependencies_list:
        content = preprocess_files(dep)
        with open(f"{SYNTH_DIR}/rtl/{os.path.basename(dep)}", 'w') as f:
            f.write(content)
    os.system(f"zip -r synthesis_harness.zip synthesis")
    os.system(f"rm -rf {SYNTH_DIR}")

def main():
    if len(sys.argv) < 3:
        print("Usage: python create_synthesis_harness.py <testbench_name> <file_list>")
        sys.exit(1)

    testbench_path = sys.argv[1]
    rtl_path = os.path.abspath(testbench_path)
    flist = sys.argv[2]

    dependencies_list = get_testbench_dependencies(rtl_path, flist)


    if not dependencies_list:
        print("No dependencies found for the testbench.")
        sys.exit(1)

        
    create_synthesis_harness(dependencies_list)
    print("Synthesis harness created successfully.")


if __name__ == "__main__":
    main()


    


