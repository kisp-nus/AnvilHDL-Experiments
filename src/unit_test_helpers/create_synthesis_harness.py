import sys
import os


CUR_DIR = os.path.dirname(os.path.abspath(__file__))


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
        cleaned_dependencies = [line.replace("+incdir+", "").strip() for line in dependencies_list]
        extended_dependencies = [os.path.join(RTL_DIR, dep) for dep in os.listdir(RTL_DIR) if dep.endswith('.sv')] + cleaned_dependencies
        return extended_dependencies
    



def create_synthesis_harness(dependencies_list):
    SYNTH_DIR = os.path.join(CUR_DIR, "synthesis")
    os.makedirs(SYNTH_DIR, exist_ok=True)
    os.makedirs(os.path.join(SYNTH_DIR, "rtl"), exist_ok=True)
    print(f"Synthesis directory created at: {SYNTH_DIR}")
    for dep in dependencies_list:
        os.system(f"cp {dep} {SYNTH_DIR}/rtl/")

    
    os.system(f"zip -r synthesis_harness.zip {SYNTH_DIR}")
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


    


