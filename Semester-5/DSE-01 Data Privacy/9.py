# Explore requirements of Data Protection Regulations and develop a compliance plan.

def compliance_navigator():
    print("="*60)
    print("           DATA PROTECTION COMPLIANCE NAVIGATOR")
    print("="*60)
    
    regulations = {
        "1": {
            "name": "General Data Protection Regulation (GDPR)",
            "scope": "European Union residents' data.",
            "principles": ["Lawfulness, Fairness, Transparency", "Purpose Limitation", "Data Minimization", "Accuracy", "Storage Limitation", "Integrity and Confidentiality"]
        },
        "2": {
            "name": "Digital Personal Data Protection (DPDP) Act 2023",
            "scope": "India - digital personal data processing.",
            "principles": ["Consent-based processing", "Legitimate Uses", "Data Principal Rights", "Data Fiduciary Obligations"]
        }
    }

    while True:
        print("\nSelect a regulation to explore:")
        for key, reg in regulations.items():
            print(f"{key}. {reg['name']}")
        print("Q. Quit and show Compliance Checklist")
        
        choice = input("\nEnter choice: ").upper().strip()
        
        if choice in regulations:
            reg = regulations[choice]
            print(f"\n--- {reg['name']} ---")
            print(f"Scope: {reg['scope']}")
            print("Key Principles:")
            for p in reg['principles']:
                print(f"  - {p}")
        elif choice == 'Q':
            break
        else:
            print("Invalid choice. Please try again.")

    print("\n" + "="*60)
    print("           GENERAL COMPLIANCE CHECKLIST")
    print("="*60)
    checklist = [
        "Identify and map all personal data stored and processed.",
        "Establish a legal basis for processing (e.g., Consent).",
        "Implement a 'Privacy by Design' approach in all projects.",
        "Appoint a Data Protection Officer (DPO) if required.",
        "Set up mechanisms for Data Access Requests (SARs).",
        "Establish a data breach notification protocol (e.g., 72-hour rule).",
        "Review and update contracts with data processors/third parties.",
        "Maintain records of processing activities (ROPA)."
    ]
    
    for i, item in enumerate(checklist, 1):
        print(f"[{i}] {item}")
    
    print("\nTo ensure compliance, organizations should conduct regular impact assessments (DPIAs).")
    print("="*60)

if __name__ == "__main__":
    compliance_navigator()