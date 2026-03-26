# The AI That Tested Itself

So I built this thing. An AI that helps people think through what to build before they build it. I call it ido4shape → it's a Claude Code plugin, runs in Cowork, no backend, no infrastructure. Just markdown files with prompts, skills, and agents wired together. Took me a few weeks.

Its job is deceptively simple: have a real conversation with a PM or a founder or a tech lead about what they need to build. Not fill a template. Not walk through a checklist. Actually think together. Probe the vague stuff. Push back. Surface the contradictions.

Why? Because I've seen too many projects fail not because of bad code, but because nobody thought hard enough before coding started. I wrote about this before → when execution becomes cheap, thinking becomes the scarce resource. Well, I decided to try to build a tool that forces that thinking to happen.

125 tests passing. Ten skills. Five sub-agents. Hooks, canvas management, the whole thing.

And then I sat there looking at it, and I realized: I have absolutely no idea if it's any good.

## You can't unit test a conversation

All my tests checked structure. Does the plugin load? Do the hooks fire? Is the format right? Great.

But none of that tells me whether the agent asks good questions. Whether it catches when someone contradicts themselves. Whether the spec it produces at the end actually captures what was discussed → or quietly drops half of it.

How do you test a thinking partner? Go ahead, try to write an assertion for "did it make the human think harder?" I'll wait.

I needed to use it. On something real.

## So I used it on itself

This is where it gets a bit weird. Or maybe elegant, depending on how you look at it.

I needed a synthetic testing framework for ido4shape → something that runs automated conversations with fake personas and evaluates the results. That's a real project. It needs a real spec. And I have a tool that creates specs.

So I opened Cowork, loaded ido4shape, and said: help me figure out what this testing system needs to be.

Two sessions. Bunch of hours. The full pipeline → discovery conversation, probing, decisions, synthesis, validation, review, refinement. The whole thing end to end.

And look, the agent did some genuinely impressive stuff. It reframed my thinking in ways I hadn't considered. I had been treating testing and research as equally important → the agent pushed me to pick: testing first, research later. I was thinking about spec quality in terms of "is it readable?" → the agent reframed it as "can the downstream AI agent decompose this?" Which is a much sharper question.

These weren't things I told it. It proposed them. That's the thinking partner working.

But then.

## Twelve observations. That's what I got.

Not twelve compliments. Twelve problems.

I watched the agent work, and I wrote down everything that went sideways. Some of them are a bit painful, honestly. Here are the four that hit hardest:

**It lost 30% of my plan during synthesis.** I had given it a detailed 1,200-line planning document. Hidden constraints for personas, behavioral triggers, a whole trait library, data architecture, cost control hierarchy. The agent discussed all of this at a high level during the conversation. Then when it synthesized the spec → poof. Gone. The specific mechanisms disappeared.

I asked it why. And I'll give it this: the self-diagnosis was honest and accurate. Three real causes. The synthesis agent works from the conversation canvas, not the source documents. The conversation abstracted away from the specifics. And the synthesizer runs in a fresh context that doesn't carry the implicit endorsements from hours of discussion.

Fair. But still → 30% of content, lost.

**The agent talks too much.** Multiple questions per turn. Paragraphs of context before getting to the actual question. And here's what really got me: when I said "I'm not sure" about something, it asked *more* questions. Instead of saying "here's what I'd suggest, based on what you've told me."

A real thinking partner proposes when you're stuck. This one kept extracting, even when there was nothing left to extract.

**It skipped its own safety net.** The system has a review step → three independent AI reviewers that check the spec before synthesis. Technical feasibility, scope alignment, dependency logic. The agent skipped it. Went straight from conversation to synthesis without even mentioning the option.

Later I ran the review manually. The dependency auditor found errors. Errors that the synthesizer created and the validation didn't catch. The safety net was right there. The agent just... walked past it.

**Decisions shifted without anyone noticing.** My plan used one technical approach for the simulation engine. The spec described a completely different one. The switch happened naturally during conversation → we discussed it, it made sense in context. But the agent never flagged it as a decision. Never logged it. Never wrote it down.

If I hadn't compared the plan and the spec side by side, the contradiction would have shipped. An implementation agent would have built the wrong thing.

## Here's the part I didn't expect

Those twelve observations → they're not bugs. Or better said, they're not *just* bugs.

They're the test cases.

The spec I just created describes a synthetic testing framework. A system that runs fake personas through ido4shape and evaluates what happens. And now I know exactly what that system needs to catch → because I just watched those failures happen live.

The agent that was too chatty? That's a measurable signal: questions per turn, turn length trend, propose-to-ask ratio. The lost content? That's a traceability check: what was discussed vs. what ended up in the spec. The skipped review? That's a pipeline compliance check.

Every manual observation became an automated test signal. The first real-world test produced the calibration baseline for the testing system it just specced.

I didn't plan this. It just... happened. The tool, by being honestly imperfect, generated the data I needed to make it better.

## What's the spec worth, then?

After the twelve observations, I refined the spec. Ran the review I should have run earlier. Fixed the dependencies. Fixed the format (three rounds of format issues → the synthesizer is sloppy with mechanical rules, which is its own interesting observation). Validated everything.

The final result: five groups of work, seventeen capabilities, all dependencies valid, format compliant, rich enough for the next AI in the pipeline to decompose into technical implementation tasks.

Is it perfect? No. Is it good enough to build from? Yes. Is it honest about what it doesn't know? Also yes → open questions are marked as open, not disguised as decisions.

Usefully imperfect. Which, honestly, is what I want from a thinking partner.

## So what?

I've been writing lately about how AI is changing product development. The frameworks are dying. Execution is getting cheap. Feature factories are about to go supernova. And in all of that noise, the thing that matters most → the actual thinking about what to build and why → is the thing nobody's automating well.

What I learned from this experiment: building the AI agent is the easy part. Knowing whether it's good? That's the real problem. And the only way I found to approach it is unglamorous → use it, watch it carefully, write down what goes wrong, and build systems to catch those things automatically.

No shortcut. No framework for it. No certification you can buy.

Just a craftsman staring honestly into a mirror they built themselves.

---

ido4shape is open source, experimental, and very much a work in progress. If you're playing with AI agents that do creative work → not code completion, but the messy ambiguous judgment-heavy stuff → I'd genuinely like to hear how you think about quality. Because I'm still figuring it out.
