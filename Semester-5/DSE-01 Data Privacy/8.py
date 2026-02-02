# Conduct a data privacy audit of an organization to identify potential vulnerabilities and risks.

def conduct_audit():
    print("="*60)
    print("       ORGANIZATION DATA PRIVACY AUDIT TOOL")
    print("="*60)
    print("\nPlease answer the following questions (yes/no):")

    questions = [
        ("Does the organization have a documented privacy policy?", "Lack of a privacy policy is a major compliance risk."),
        ("Is data encryption used for sensitive data at rest and in transit?", "Unencrypted data is vulnerable to theft and unauthorized access."),
        ("Are access controls (MFA, RBAC) implemented for sensitive systems?", "Poor access control leads to internal and external data breaches."),
        ("Does the organization conduct regular privacy training for employees?", "Human error is one of the leading causes of data leaks."),
        ("Is there a process for identifying and reporting data breaches?", "Delayed reporting can lead to legal penalties and reputation damage."),
        ("Do you minimize data collection to only what is necessary?", "Excessive data collection increases the 'blast radius' of a breach."),
        ("Are third-party vendors vetted for their privacy practices?", "Third-party risks can compromise your organization's data integrity."),
        ("Is there a secure process for data disposal/deletion?", "Improperly disposed data can be recovered by malicious actors.")
    ]

    score = 0
    recommendations = []

    for i, (q, rec) in enumerate(questions, 1):
        while True:
            response = input(f"{i}. {q} (y/n): ").lower().strip()
            if response in ['y', 'yes']:
                score += 1
                break
            elif response in ['n', 'no']:
                recommendations.append(rec)
                break
            else:
                print("Invalid input. Please enter 'y' or 'n'.")

    print("\n" + "="*60)
    print("                    AUDIT SUMMARY")
    print("="*60)
    print(f"Compliance Score: {score}/{len(questions)}")
    
    if score == len(questions):
        print("\nExcellent! Your organization follows strong data privacy practices.")
    else:
        print("\nAreas for Improvement:")
        for rec in recommendations:
            print(f"- {rec}")
    
    risk_level = "High" if score < 4 else "Medium" if score < 7 else "Low"
    print(f"\nOverall Risk Level: {risk_level}")
    print("="*60)

if __name__ == "__main__":
    conduct_audit()