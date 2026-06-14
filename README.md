# 🔐 Azure Hybrid Security Baseline


## Overview

This project documents the implementation
of a security baseline across a hybrid
environment — connecting an on-premises
Windows Server 2022 Domain Controller to
Microsoft Defender for Cloud via Azure Arc
and establishing the foundational security
posture that all subsequent security layers
depend upon.

A security baseline is not a one-time
configuration task. It is the establishment
of a known, documented, and measurable
security state from which improvement is
tracked and deviation is detected. Without
a baseline you cannot answer the most
fundamental security question an
organisation faces: are we more or less
secure than we were last month?

This project answers that question by
creating a quantifiable, automated, and
continuously assessed security foundation
across both cloud and on-premises
infrastructure.

---
## Architecture
![Architecture](Docs/architecture-diagram.png)


---

## The Problem This Solves

Security teams in hybrid environments
face a measurement problem. Cloud
workloads are assessed by cloud-native
tools. On-premises servers are assessed
by separate tools. The two pictures never
combine into a single view and leadership
cannot get a coherent answer about the
organisation's overall security posture.

The second problem is coverage. Standard
Azure security policies target Azure
resources. An on-premises Domain
Controller running on Hyper-V is invisible
to those policies by default. It sits
outside the Azure management plane,
unassessed and ungoverned by the same
frameworks applied to cloud workloads.

Microsoft Defender for Cloud with Azure
Arc solves both problems. Arc projects
the on-premises server into the Azure
management plane. Defender for Cloud
then assesses it alongside Azure resources
producing a unified Secure Score that
reflects the true security posture of
the hybrid environment as a whole.

---

## Architecture


## Understanding the Secure Score

When I first connected this hybrid
environment to Defender for Cloud the
Secure Score showed 21.79% — 51 controls
passing out of 234 assessed.

I want to address this number directly
because misunderstanding Secure Score
is one of the most common mistakes I
see discussed in Azure security
communities.

Microsoft Defender for Cloud assesses
234 controls spanning the entire Azure
service catalogue. SQL databases, App
Service applications, Container registries,
IoT hubs, Cosmos DB, and dozens of other
services all have associated controls.
In a minimal hybrid environment where
many of these services simply do not
exist, those controls show as failing
by default.

This is not a reflection of poor security
practice. It is a reflection of scope.

The controls directly relevant to this
hybrid environment — Arc connectivity,
Defender plan coverage, Log Analytics
configuration, security policy assignment,
and identity baseline — are all passing.
The failing controls relate overwhelmingly
to services not deployed in this
environment.

The correct way to read a Secure Score
in a growing environment is not as an
absolute measure but as a trajectory.
As the environment expands across
subsequent projects — network security,
private endpoints, identity hardening,
governance — each new layer of
infrastructure brings additional controls
into scope and into a passing state.

By the completion of this 14-project
portfolio the same Secure Score reflects
an 80%+ passing rate because the
environment has grown to include the
services those controls assess.

Documenting the 21.79% baseline honestly
and explaining it accurately is itself
a demonstration of security maturity.
An engineer who presents a manipulated
score is far more concerning than one
who presents a low score with clear
understanding of why it is low and
how it will improve.

---

## Why Each Defender Plan Was Enabled

Enabling all Defender plans was a
deliberate architectural decision rather
than a default selection. Each plan was
evaluated against the environment.

*Defender for Servers* was the primary
requirement. The Domain Controller is the
most sensitive asset in the on-premises
environment and the most targeted by
attackers. Endpoint detection and response
coverage on the DC is non-negotiable.

*Defender for SQL* was enabled in
anticipation of the SQL deployment in
Project 4. Enabling it at the baseline
ensures that when SQL is deployed it is
immediately covered without requiring a
return to this configuration.

*Defender for Storage and Key Vault*
follow the same forward-looking logic.
Project 4 deploys both services and they
should be protected from the moment of
creation rather than added to Defender
retroactively.

*Defender for ARM and DNS* address
control plane attacks that are frequently
overlooked. Azure Resource Manager is the
interface through which all Azure resources
are created and modified. DNS is the
foundation of network communication.
Both are high-value targets for attackers
who have obtained cloud credentials and
both generate relatively little cost
compared to the detection value they
provide.

*Defender for Containers* was enabled
in preparation for the AKS deployment
in Project 12. The same forward-looking
reasoning applies.

---

## The Log Analytics Workspace Design

A central Log Analytics workspace was
established as the collection point for
all security telemetry across the entire
14-project portfolio. This was a
deliberate architectural decision made
at the baseline stage because changing
workspace architecture later is
disruptive and expensive.

The alternative of using separate
workspaces per project or per service
creates the same fragmentation problem
that hybrid identity was designed to
solve — data lives in silos and
correlation across the environment
becomes difficult or impossible.

A single central workspace means that a
Sentinel analytics rule can correlate a
suspicious authentication event from
the on-premises Domain Controller with
an anomalous API call from an Azure
resource and a data access event from
a storage account — in a single query,
producing a single alert, investigated
by a single analyst in a single interface.

The 90-day retention period was chosen
to align with common regulatory
requirements for security log retention
and to provide sufficient historical
data for threat hunting activities that
look back across extended timeframes.

---

## Custom Policy — Why It Matters

The three built-in policies assigned —
Azure Security Benchmark v3, Windows
Server 2022 baseline, and hybrid machine
policy — cover standard scenarios.

The custom policy I created addresses
a gap specific to this environment:
restricting Arc-connected machines to
UK South region.

This matters for two reasons. The first
is data residency. Security telemetry
from the Domain Controller should remain
within UK geography for compliance
purposes. The second is operational
governance — an Arc server registered
to an unexpected region could indicate
an unauthorised server being enrolled
in the management plane, which is a
meaningful security signal.

Writing a custom policy rather than
relying entirely on built-in assignments
demonstrates that security governance
requires adaptation to specific
environments. Built-in policies are
starting points. Mature security
programmes extend them.

---

## Security Contacts and Alert Routing

Configuring security contacts in Defender
for Cloud is a step that is easy to skip
because it does not directly affect the
Secure Score and produces no visible
infrastructure change. It is also one
of the most important operational
configurations in the entire baseline.

When Defender for Cloud detects a high
severity threat it needs to know who
to tell. Without security contacts that
notification goes nowhere. A threat is
detected, an alert is generated, and it
sits unread in the portal until someone
happens to look.

I configured security contacts with
email alerting to subscription owners
and security administrators. This ensures
that regardless of whether the security
portal is actively monitored, critical
detections produce immediate notification
to the people responsible for responding
to them.

---

## Challenges Encountered

**Auto-provisioning and the MMA to AMA
transition**

During implementation I encountered the
Microsoft Monitoring Agent versus Azure
Monitoring Agent decision. Microsoft is
deprecating MMA in favour of AMA but at
the time of implementation not all Defender
for Cloud features had completed migration
to AMA. I resolved this by deploying MMA
for immediate Defender for Cloud
integration while documenting the AMA
migration path for when feature parity
is achieved — a real-world architectural
decision that pure lab environments
rarely surface.

*Secure Score latency*

After enabling Defender plans and
assigning policies, Secure Score changes
do not appear immediately. Assessment
results can take 24-48 hours to refresh.
This is frequently misunderstood as a
configuration error. Understanding that
Defender for Cloud operates on an
asynchronous assessment cycle is
important for setting accurate
expectations when implementing in
production environments.

*Custom policy propagation*

Custom policy assignments propagate to
resources based on the Azure Policy
evaluation cycle which runs every 24
hours by default. Triggering an on-demand
evaluation using Start-AzPolicyComplianceScan
was necessary to verify the custom policy
was functioning correctly without waiting
for the next natural evaluation cycle.

---

## What This Baseline Enables

Every security project in this portfolio
builds on what is established here.

The central Log Analytics workspace
receives security events from every
subsequent deployment. Sentinel analytics
rules created in Project 5 query data
that begins flowing in this project.
Defender for Cloud assessments of
resources deployed in Projects 3, 4,
and 10 appear in the same Secure Score
established here. Custom RBAC roles
defined in Project 8 govern access to
the workspace created here.

The baseline is not one project among
fourteen. It is the foundation that
makes all fourteen projects a coherent
security programme rather than a
collection of disconnected exercises.

---

## Lessons Learned

The most important lesson from this
project was about the relationship
between measurement and improvement.
Establishing a Secure Score baseline —
even a low one — gives you something
that many security teams do not have:
a starting point you can prove and a
trajectory you can demonstrate.

In interview settings and client
conversations the ability to say
"our baseline was X, we implemented
these controls, and our score improved
to Y" is far more compelling than any
certification or theoretical knowledge.
Security is ultimately about reducing
risk measurably. This project creates
the measurement framework.

The second lesson was about the
importance of enabling controls in
anticipation of future deployments.
Enabling Defender for Storage before
the storage account is deployed means
the account is protected from the
moment it exists. Retrofitting
protection after deployment is not
just operationally inconvenient —
there is a window of exposure between
resource creation and protection
enablement that should not exist.

---

## What I Would Do Differently at Scale

At enterprise scale I would implement
Defender for Cloud at the Management
Group level rather than the subscription
level, ensuring that any new subscription
created within the organisation
automatically inherits the security
baseline without requiring manual
configuration.

I would also implement the Defender
for Cloud export to Event Hub for
integration with enterprise SIEM
platforms beyond Sentinel, providing
flexibility for organisations that
operate multiple security tools.

The Log Analytics workspace would be
configured with data collection rules
at the workspace level combined with
transformation rules to filter and
enrich events before storage —
reducing ingestion costs while improving
query performance for the security
operations team.

---

Uzma Shabbir
Azure Security Engineer | AZ-104 | AZ-500
[GitHub](https://github.com/UzmaSami) •
[LinkedIn](https://linkedin.com/in/uzma-shabbir-034361128)
