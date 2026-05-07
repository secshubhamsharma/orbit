require("dotenv").config();
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const library = [
  {
    domain: {
      id: "it_certifications",
      name: "IT Certifications",
      description: "Industry-recognised certifications for networking, cloud, and security professionals.",
      colorHex: "#7C6FE8",
      order: 1,
    },
    subjects: [
      {
        id: "networking",
        name: "Networking",
        applicableExams: ["ccna", "ccnp", "network+"],
        totalTopics: 2,
        order: 1,
        books: [
          {
            id: "ccna",
            title: "Cisco CCNA 200-301",
            authors: ["Wendell Odom"],
            description: "Complete guide for the CCNA 200-301 exam covering networking fundamentals, IP connectivity, security, and automation.",
            examTags: ["ccna", "cisco"],
            totalChapters: 8,
            order: 1,
            chapters: [
              { id: "ccna-ch1", chapterNumber: 1, name: "Networking Fundamentals", difficulty: "beginner", estimatedMinutes: 15, tags: ["osi", "tcp-ip", "models"] },
              { id: "ccna-ch2", chapterNumber: 2, name: "Ethernet & Switching", difficulty: "beginner", estimatedMinutes: 20, tags: ["ethernet", "vlans", "stp"] },
              { id: "ccna-ch3", chapterNumber: 3, name: "IPv4 Addressing & Subnetting", difficulty: "intermediate", estimatedMinutes: 25, tags: ["subnetting", "cidr", "vlsm"] },
              { id: "ccna-ch4", chapterNumber: 4, name: "Routing Protocols", difficulty: "intermediate", estimatedMinutes: 20, tags: ["ospf", "eigrp", "static-routing"] },
              { id: "ccna-ch5", chapterNumber: 5, name: "VLANs & Inter-VLAN Routing", difficulty: "intermediate", estimatedMinutes: 20, tags: ["vlans", "trunking", "router-on-stick"] },
              { id: "ccna-ch6", chapterNumber: 6, name: "WAN Technologies", difficulty: "intermediate", estimatedMinutes: 15, tags: ["wan", "vpn", "mpls"] },
              { id: "ccna-ch7", chapterNumber: 7, name: "Security Fundamentals", difficulty: "advanced", estimatedMinutes: 20, tags: ["acl", "nat", "aaa"] },
              { id: "ccna-ch8", chapterNumber: 8, name: "Automation & Programmability", difficulty: "advanced", estimatedMinutes: 15, tags: ["python", "restconf", "netconf"] },
            ],
          },
          {
            id: "network-plus",
            title: "CompTIA Network+",
            authors: ["Mike Meyers"],
            description: "Covers networking concepts, infrastructure, operations, security, and troubleshooting for the N10-008 exam.",
            examTags: ["network+", "comptia"],
            totalChapters: 6,
            order: 2,
            chapters: [
              { id: "net-ch1", chapterNumber: 1, name: "Network Architecture", difficulty: "beginner", estimatedMinutes: 15, tags: ["topologies", "types", "architecture"] },
              { id: "net-ch2", chapterNumber: 2, name: "Network Devices & Cabling", difficulty: "beginner", estimatedMinutes: 15, tags: ["switches", "routers", "cables"] },
              { id: "net-ch3", chapterNumber: 3, name: "IP Addressing", difficulty: "intermediate", estimatedMinutes: 20, tags: ["ipv4", "ipv6", "dhcp"] },
              { id: "net-ch4", chapterNumber: 4, name: "Routing & Switching", difficulty: "intermediate", estimatedMinutes: 20, tags: ["routing", "spanning-tree", "vlans"] },
              { id: "net-ch5", chapterNumber: 5, name: "Network Security", difficulty: "advanced", estimatedMinutes: 20, tags: ["firewalls", "ids", "vpn"] },
              { id: "net-ch6", chapterNumber: 6, name: "Troubleshooting", difficulty: "advanced", estimatedMinutes: 15, tags: ["methodology", "tools", "diagnosis"] },
            ],
          },
        ],
      },
      {
        id: "cloud",
        name: "Cloud Computing",
        applicableExams: ["aws-saa", "aws-clf", "gcp-ace"],
        totalTopics: 2,
        order: 2,
        books: [
          {
            id: "aws-saa",
            title: "AWS Solutions Architect Associate",
            authors: ["Stephane Maarek"],
            description: "Comprehensive preparation for the SAA-C03 exam covering compute, storage, databases, networking, and security on AWS.",
            examTags: ["aws", "aws-saa", "cloud"],
            totalChapters: 8,
            order: 1,
            chapters: [
              { id: "aws-ch1", chapterNumber: 1, name: "IAM & Security", difficulty: "beginner", estimatedMinutes: 15, tags: ["iam", "mfa", "policies"] },
              { id: "aws-ch2", chapterNumber: 2, name: "EC2 & Auto Scaling", difficulty: "beginner", estimatedMinutes: 20, tags: ["ec2", "ami", "autoscaling"] },
              { id: "aws-ch3", chapterNumber: 3, name: "Storage: S3, EBS & EFS", difficulty: "intermediate", estimatedMinutes: 20, tags: ["s3", "ebs", "efs", "storage"] },
              { id: "aws-ch4", chapterNumber: 4, name: "VPC & Networking", difficulty: "intermediate", estimatedMinutes: 25, tags: ["vpc", "subnets", "nacl", "security-groups"] },
              { id: "aws-ch5", chapterNumber: 5, name: "Databases: RDS, DynamoDB & ElastiCache", difficulty: "intermediate", estimatedMinutes: 20, tags: ["rds", "dynamodb", "elasticache"] },
              { id: "aws-ch6", chapterNumber: 6, name: "High Availability & Disaster Recovery", difficulty: "advanced", estimatedMinutes: 20, tags: ["elb", "route53", "failover"] },
              { id: "aws-ch7", chapterNumber: 7, name: "Serverless: Lambda, API Gateway & SQS", difficulty: "advanced", estimatedMinutes: 20, tags: ["lambda", "api-gateway", "sqs", "sns"] },
              { id: "aws-ch8", chapterNumber: 8, name: "Cost Optimisation & Well-Architected", difficulty: "advanced", estimatedMinutes: 15, tags: ["cost", "well-architected", "trusted-advisor"] },
            ],
          },
          {
            id: "aws-clf",
            title: "AWS Cloud Practitioner",
            authors: ["Neal Davis"],
            description: "Entry-level AWS certification covering cloud concepts, core services, security, and billing for the CLF-C02 exam.",
            examTags: ["aws", "aws-clf", "cloud"],
            totalChapters: 5,
            order: 2,
            chapters: [
              { id: "clf-ch1", chapterNumber: 1, name: "Cloud Concepts", difficulty: "beginner", estimatedMinutes: 12, tags: ["cloud", "benefits", "models"] },
              { id: "clf-ch2", chapterNumber: 2, name: "Core AWS Services", difficulty: "beginner", estimatedMinutes: 20, tags: ["ec2", "s3", "rds", "vpc"] },
              { id: "clf-ch3", chapterNumber: 3, name: "Security & Compliance", difficulty: "intermediate", estimatedMinutes: 15, tags: ["iam", "shield", "waf", "compliance"] },
              { id: "clf-ch4", chapterNumber: 4, name: "Pricing & Billing", difficulty: "beginner", estimatedMinutes: 12, tags: ["pricing", "cost-explorer", "support"] },
              { id: "clf-ch5", chapterNumber: 5, name: "Cloud Architecture", difficulty: "intermediate", estimatedMinutes: 15, tags: ["well-architected", "availability", "scalability"] },
            ],
          },
        ],
      },
      {
        id: "security",
        name: "Cybersecurity",
        applicableExams: ["security+", "ceh"],
        totalTopics: 1,
        order: 3,
        books: [
          {
            id: "security-plus",
            title: "CompTIA Security+",
            authors: ["Darril Gibson"],
            description: "Covers threats, attacks, cryptography, identity management, risk management, and compliance for the SY0-701 exam.",
            examTags: ["security+", "comptia"],
            totalChapters: 7,
            order: 1,
            chapters: [
              { id: "sec-ch1", chapterNumber: 1, name: "Threats, Attacks & Vulnerabilities", difficulty: "beginner", estimatedMinutes: 20, tags: ["malware", "social-engineering", "vulnerabilities"] },
              { id: "sec-ch2", chapterNumber: 2, name: "Architecture & Design", difficulty: "intermediate", estimatedMinutes: 15, tags: ["zero-trust", "cloud-security", "virtualization"] },
              { id: "sec-ch3", chapterNumber: 3, name: "Implementation", difficulty: "intermediate", estimatedMinutes: 20, tags: ["protocols", "wireless", "pki"] },
              { id: "sec-ch4", chapterNumber: 4, name: "Operations & Incident Response", difficulty: "intermediate", estimatedMinutes: 15, tags: ["incident-response", "forensics", "siem"] },
              { id: "sec-ch5", chapterNumber: 5, name: "Governance, Risk & Compliance", difficulty: "advanced", estimatedMinutes: 15, tags: ["grc", "frameworks", "policies"] },
              { id: "sec-ch6", chapterNumber: 6, name: "Cryptography & PKI", difficulty: "advanced", estimatedMinutes: 20, tags: ["encryption", "hashing", "certificates"] },
              { id: "sec-ch7", chapterNumber: 7, name: "Identity & Access Management", difficulty: "advanced", estimatedMinutes: 15, tags: ["iam", "mfa", "federation"] },
            ],
          },
        ],
      },
    ],
  },
  {
    domain: {
      id: "competitive_exams",
      name: "Competitive Exams",
      description: "Structured preparation for JEE, NEET, UPSC, GATE, CAT, SSC, and Banking exams.",
      colorHex: "#FF6B9D",
      order: 2,
    },
    subjects: [
      {
        id: "jee-physics",
        name: "Physics (JEE)",
        applicableExams: ["jee-mains", "jee-advanced"],
        totalTopics: 1,
        order: 1,
        books: [
          {
            id: "jee-physics",
            title: "JEE Physics Complete Guide",
            authors: ["H.C. Verma", "D.C. Pandey"],
            description: "Chapter-wise MCQ practice for JEE Physics covering all topics from mechanics to modern physics.",
            examTags: ["jee-mains", "jee-advanced"],
            totalChapters: 8,
            order: 1,
            chapters: [
              { id: "jee-phy-ch1", chapterNumber: 1, name: "Mechanics & Laws of Motion", difficulty: "intermediate", estimatedMinutes: 25, tags: ["newton", "friction", "momentum"] },
              { id: "jee-phy-ch2", chapterNumber: 2, name: "Work, Energy & Power", difficulty: "intermediate", estimatedMinutes: 20, tags: ["energy", "work", "collisions"] },
              { id: "jee-phy-ch3", chapterNumber: 3, name: "Thermodynamics", difficulty: "intermediate", estimatedMinutes: 20, tags: ["heat", "entropy", "gas-laws"] },
              { id: "jee-phy-ch4", chapterNumber: 4, name: "Electrostatics", difficulty: "advanced", estimatedMinutes: 25, tags: ["coulombs-law", "capacitors", "gauss"] },
              { id: "jee-phy-ch5", chapterNumber: 5, name: "Current Electricity", difficulty: "advanced", estimatedMinutes: 20, tags: ["ohms-law", "kirchhoff", "circuits"] },
              { id: "jee-phy-ch6", chapterNumber: 6, name: "Magnetism & EMI", difficulty: "advanced", estimatedMinutes: 20, tags: ["biot-savart", "faraday", "lenz"] },
              { id: "jee-phy-ch7", chapterNumber: 7, name: "Optics", difficulty: "intermediate", estimatedMinutes: 20, tags: ["reflection", "refraction", "wave-optics"] },
              { id: "jee-phy-ch8", chapterNumber: 8, name: "Modern Physics", difficulty: "advanced", estimatedMinutes: 20, tags: ["photoelectric", "nuclei", "semiconductor"] },
            ],
          },
        ],
      },
      {
        id: "upsc-gs",
        name: "UPSC General Studies",
        applicableExams: ["upsc-prelims", "upsc-mains"],
        totalTopics: 1,
        order: 2,
        books: [
          {
            id: "upsc-gs",
            title: "UPSC General Studies Paper 1",
            authors: ["M. Laxmikanth", "NCERT"],
            description: "Comprehensive MCQ practice for UPSC Prelims GS Paper 1 covering history, geography, polity, economy, and environment.",
            examTags: ["upsc-prelims"],
            totalChapters: 6,
            order: 1,
            chapters: [
              { id: "upsc-ch1", chapterNumber: 1, name: "Indian History & Freedom Struggle", difficulty: "intermediate", estimatedMinutes: 25, tags: ["ancient", "medieval", "modern", "freedom"] },
              { id: "upsc-ch2", chapterNumber: 2, name: "Indian Polity & Governance", difficulty: "intermediate", estimatedMinutes: 25, tags: ["constitution", "parliament", "judiciary"] },
              { id: "upsc-ch3", chapterNumber: 3, name: "Indian & World Geography", difficulty: "intermediate", estimatedMinutes: 20, tags: ["physical", "rivers", "climate"] },
              { id: "upsc-ch4", chapterNumber: 4, name: "Indian Economy", difficulty: "advanced", estimatedMinutes: 20, tags: ["planning", "budget", "banking"] },
              { id: "upsc-ch5", chapterNumber: 5, name: "Environment & Ecology", difficulty: "intermediate", estimatedMinutes: 15, tags: ["biodiversity", "conservation", "climate-change"] },
              { id: "upsc-ch6", chapterNumber: 6, name: "Science & Technology", difficulty: "intermediate", estimatedMinutes: 15, tags: ["space", "defence", "biotech"] },
            ],
          },
        ],
      },
    ],
  },
  {
    domain: {
      id: "finance_certifications",
      name: "Finance Certifications",
      description: "CFA, FRM, and other globally recognised finance certifications.",
      colorHex: "#FFD43B",
      order: 3,
    },
    subjects: [
      {
        id: "cfa",
        name: "CFA Program",
        applicableExams: ["cfa-level-1"],
        totalTopics: 1,
        order: 1,
        books: [
          {
            id: "cfa-l1",
            title: "CFA Level 1 Essentials",
            authors: ["CFA Institute"],
            description: "Chapter-wise MCQ practice for CFA Level 1 covering ethics, quantitative methods, economics, financial reporting, and portfolio management.",
            examTags: ["cfa-level-1"],
            totalChapters: 6,
            order: 1,
            chapters: [
              { id: "cfa-ch1", chapterNumber: 1, name: "Ethics & Professional Standards", difficulty: "intermediate", estimatedMinutes: 20, tags: ["ethics", "standards", "ips"] },
              { id: "cfa-ch2", chapterNumber: 2, name: "Quantitative Methods", difficulty: "advanced", estimatedMinutes: 25, tags: ["statistics", "probability", "regression"] },
              { id: "cfa-ch3", chapterNumber: 3, name: "Economics", difficulty: "intermediate", estimatedMinutes: 20, tags: ["microeconomics", "macroeconomics", "monetary-policy"] },
              { id: "cfa-ch4", chapterNumber: 4, name: "Financial Statement Analysis", difficulty: "advanced", estimatedMinutes: 25, tags: ["income-statement", "balance-sheet", "ratios"] },
              { id: "cfa-ch5", chapterNumber: 5, name: "Equity & Fixed Income", difficulty: "advanced", estimatedMinutes: 25, tags: ["equities", "bonds", "valuation"] },
              { id: "cfa-ch6", chapterNumber: 6, name: "Portfolio Management", difficulty: "advanced", estimatedMinutes: 20, tags: ["capm", "risk", "diversification"] },
            ],
          },
        ],
      },
    ],
  },
];

async function seedDomain(domainData) {
  const domainRef = db.collection("domains").doc(domainData.domain.id);
  await domainRef.set(domainData.domain, { merge: true });
  console.log(`  ✅ Domain: ${domainData.domain.name}`);

  for (const subject of domainData.subjects) {
    const { books, ...subjectData } = subject;
    const subjectRef = domainRef.collection("subjects").doc(subject.id);
    await subjectRef.set({ ...subjectData, domainId: domainData.domain.id }, { merge: true });
    console.log(`    ✅ Subject: ${subject.name}`);

    for (const book of books) {
      const { chapters, ...bookData } = book;
      const bookRef = subjectRef.collection("books").doc(book.id);
      await bookRef.set({
        ...bookData,
        domainId: domainData.domain.id,
        subjectId: subject.id,
      }, { merge: true });
      console.log(`      ✅ Book: ${book.title} (id: ${book.id})`);

      for (const chapter of chapters) {
        const chapterRef = bookRef.collection("chapters").doc(chapter.id);
        await chapterRef.set({
          ...chapter,
          bookId: book.id,
          subjectId: subject.id,
          domainId: domainData.domain.id,
          totalCards: 0,
          generatedByAI: true,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }
      console.log(`        ✅ ${chapters.length} chapters seeded`);
    }
  }
}

async function run() {
  console.log("🚀 Seeding Orbit library to Firestore...\n");

  for (const entry of library) {
    await seedDomain(entry);
  }

  console.log("\n✅ Seed complete. Run the app to see the library.");
  process.exit(0);
}

run().catch((err) => {
  console.error("❌ Seed failed:", err.message);
  process.exit(1);
});
