# Week 2 – AI Integration & Enhanced Security Operations

This week focuses on implementing AI-driven capabilities within the Defender for Cloud infrastructure established in Week 1. The goal is to explore cost-effective AI integration patterns and build practical automation workflows that enhance security operations.

## 🎯 Objectives

- Implement Azure OpenAI + Sentinel integration for cost-effective AI automation.
- Enable built-in AI features (UEBA, Fusion, Anomaly Detection) within existing deployments.
- Configure cost monitoring and alerts for AI services to stay within budget.
- Create foundational prompt templates for security scenarios.
- Simulate threat scenarios to observe AI-driven insights and responses.
- Begin building a prompt library that supports real-world security operations.
- Document AI integration patterns and cost optimization strategies.

## 📁 Deliverables

- Azure OpenAI + Sentinel integration implemented using Logic Apps.
- Built-in AI features (UEBA, Fusion, Anomaly Detection) enabled and validated.
- Cost monitoring and alerting configured for AI services (within $150/month budget).
- Basic prompt templates created for:
  - Threat detection and alert triage
  - Security incident summarization
  - AI-assisted remediation guidance
- Simulated threat scenarios executed with AI analysis captured.
- AI integration guide and cost optimization strategies published.

## ✅ Checklist

- [x] AI-driven security recommendations research completed (from Week 1).
- [ ] **Storage Account Deployment** - Deploy storage accounts for AI data processing, model storage, and logging.
- [ ] Azure OpenAI + Sentinel integration implemented (Logic Apps).
- [ ] Built-in AI features enabled (UEBA, Fusion, Anomaly Detection).
- [ ] Azure cost alerts configured for AI services.
- [ ] Basic AI prompt templates created for security scenarios.
- [ ] Benign threat scenario simulated with AI analysis.
- [ ] AI integration cost optimization strategies documented.
- [ ] Security Copilot research and on-demand usage strategy documented.
- [ ] AI integration guide published to GitHub Pages.
- [ ] Week 2 foundation prepared for Week 3 XDR integration.

> **📋 Infrastructure Note**: Storage accounts are required for AI workloads including data processing, model storage, and logging. These should be deployed early in Week 2 before implementing AI services.

## 📂 Project Files

This week's project builds on Week 1's infrastructure with AI-focused enhancements:

### 🔬 Research & Strategy

- **[AI-Driven Security Recommendations Research](../reports/full-ai-driven-security-recommendations-research.md)** - Comprehensive research report on cost-effective AI integration strategies (completed in Week 1).

### 🤖 AI Integration

- **[Unified Security Operations Configuration](./modernization/UNIFIED-SECURITY-CONFIGURATION.md)** - Comprehensive guide for configuring the advanced unified security operations capabilities validated in Week 1.
- **[Azure OpenAI + Sentinel Integration Guide](./ai-integration-guide.md)** - Step-by-step guide for implementing cost-effective AI-driven alert summarization using Logic Apps and Azure OpenAI.
- **[AI Prompt Templates](./ai-prompt-templates.md)** - Basic prompt templates for security scenarios including alert triage, threat detection, and remediation guidance.
- **[AI Cost Management Strategy](./ai-cost-management.md)** - Comprehensive cost monitoring and optimization strategies for AI services.

### 🏗️ Enhanced Infrastructure

- **[AI-Enhanced Bicep Templates](./infra-ai/)** - Enhanced infrastructure templates with AI service integration.
- **[AI Integration Scripts](./scripts-ai/)** - PowerShell scripts for AI service deployment and configuration.

## 🎯 Weekly Focus Areas

### **Phase 1: Cost-Effective AI Integration (Monday-Wednesday)**

- Implement Azure OpenAI + Sentinel integration using Logic Apps
- Configure cost monitoring and alerting for AI services
- Enable built-in AI features (UEBA, Fusion, Anomaly Detection)

### **Phase 2: Practical AI Implementation (Thursday-Friday)**

- Create basic prompt templates for security scenarios
- Simulate threat scenarios and capture AI insights
- Document cost optimization strategies

### **Phase 3: Foundation for Advanced Integration (Weekend)**

- Research Security Copilot on-demand strategies
- Prepare for Week 3 XDR integration
- Publish AI integration guide

---

## 🔗 Related Resources

- [Week 1: Defender for Cloud Deployment Mastery](../01%20-%20Defender%20for%20Cloud%20Deployment%20Mastery/README.md)
- [Week 3: Defender XDR + Security Copilot Integration](../03%20-%20Defender%20XDR%20+%20Security%20Copilot%20Integration/README.md)
- [Project Root](/Microsoft/Azure%20Ai%20Security%20Skills%20Challenge/README.md)

---