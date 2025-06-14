from aiexec.components.input_output import ChatInput, ChatOutput
from aiexec.components.prompts import PromptComponent
from aiexec.graph import Graph
from aiexec.schema.message import Message

from tests.integration.utils import run_flow


async def test_simple_no_llm():
    graph = Graph()
    flow_input = graph.add_component(ChatInput())
    flow_output = graph.add_component(ChatOutput())
    component = PromptComponent(template="This is the message: {var1}", var1="")
    prompt = graph.add_component(component)
    graph.add_component_edge(flow_input, ("message", "var1"), prompt)
    graph.add_component_edge(prompt, ("prompt", "input_value"), flow_output)
    outputs = await run_flow(graph, run_input="hello!")
    assert isinstance(outputs["message"], Message)
    assert outputs["message"].text == "This is the message: hello!"
