# Making Life Easy For Designers In Opencode

REMEMBER: THIS IS FOR OPENCODE NOT CLAUDE

tl;dr -- our designers are going to be making Daisy UI components inside of their own repository

Our application will depend on it

this is the playground which they will be building these things

we want to give them guardrails that make it so that things are set up in a way that deisgners do NOT have to be concerned with a few things.

-- we want to make sure that on boot asks whether you want to ideate, create, or update a component or function of design in the application
-- we want to have guard rails in place that are test-first so that they can think about deliverables of what they need and use the tests to guide their own thought processes
-- make sure those tests are outputting SCREENSHOTS we want them to SEE THINGS
-- want to have a way for the machine to have a living memory of what exists in its design system
-- we want the machine to totally take away systemic running stuff like phoenix servers or utilizing git or even havin to write up a pull request manually, the only thing they should need to do is take screenshots and cmd+click the github PR link shared then edit the body to add them
-- screenshot/figma MCP/whatever driven devleopment coupled with those tests

Considering these points, we are going to be building a proof of concept series of guardrails and special agent that will allow them to do this

the first thing we want to do here is upon opening opencode, have the designers be prompted with something simple:

Do you want to CREATE, IDEATE, or UPDATE a component?

The system should be TOTALLY focused on components.

Action Items;

1. Get a page up in the app that has 3 basic components on it:
  - a calendar datepicker
  - a button that has a loading animation once its pressed until toold otherwise by props to stop being a loader
  - a simple table that displays some data given to it

Once we have these 3 components we want to begin thinkinga bout how to add things for the above process

2. Get a Plugin for Opencode that asks that initial question
3. Once the initial question is asked, have a series of guidelines about making sure YOU the ROBOT are not going off the rails
  -- minimal server stuff, we need to show off interaction but NOTHING MORE
  -- stub data, keep it fast
  -- REMEMBER, to START WITH TESTS, we want them to DESIGN TESTS
    - these tests will guide the actual design of the component 
    - they will force thinking through the full interactions
    - they will enforce the color schemes, design and more

We also will have a system that is baked in to give default colors, default styles, etc that will need to be referenced, make a super basic implementation of this
