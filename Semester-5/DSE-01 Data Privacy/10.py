# Explore ethical considerations, privacy vs. security, and impact on marginalized communities.


def ethics_explorer():
    print("="*60)
    print("           DATA PRIVACY ETHICS EXPLORER")
    print("="*60)
    
    case_studies = [
        {
            "title": "Predictive Policing",
            "scenario": "A city uses AI to predict where crimes will occur based on historical data.",
            "ethical_issue": "Legacy data often contains human bias, leading to over-policing of marginalized communities.",
            "discussion": "Does the incremental increase in security justify the potential for systematic discrimination?"
        },
        {
            "title": "Contact Tracing Apps",
            "scenario": "During a pandemic, governments use mobile apps to track people's movements to stop virus spread.",
            "ethical_issue": "Constant surveillance of movement can be normalized and misused for political suppression.",
            "discussion": "How do we ensure that 'emergency' surveillance ends when the emergency does?"
        },
        {
            "title": "Free Services for Data (The 'Free' Trap)",
            "scenario": "Social media platforms provide free services in exchange for detailed behavioral data.",
            "ethical_issue": "Users often don't understand the depth of profiling or how it influences their behavior (e.g., echo chambers).",
            "discussion": "Is it ethical to trade fundamental privacy for convenience if there are no viable alternatives?"
        }
    ]

    for i, case in enumerate(case_studies, 1):
        print(f"\nCase Study {i}: {case['title']}")
        print(f"Scenario: {case['scenario']}")
        input("Press Enter to see the ethical issue...")
        print(f"Ethical Issue: {case['ethical_issue']}")
        print(f"Discussion Point: {case['discussion']}")
        print("-" * 30)

    print("\n" + "="*60)
    print("                    KEY ETHICAL PILLARS")
    print("="*60)
    pillars = [
        ("Transparency", "Users should know exactly what is being collected and why."),
        ("Accountability", "Developers and organizations must be responsible for data misuse."),
        ("Justice/Fairness", "Data practices should not disproportionately harm vulnerable groups."),
        ("Autonomy", "Individuals should have meaningful control over their personal data.")
    ]
    
    for title, desc in pillars:
        print(f"- {title}: {desc}")
    
    print("\nConclusion: Data ethics is not just about compliance, but about doing what's right for society.")
    print("="*60)

if __name__ == "__main__":
    ethics_explorer()