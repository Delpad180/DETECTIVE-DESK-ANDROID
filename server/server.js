import express from "express";
import helmet from "helmet";
import rateLimit from "express-rate-limit";

const app = express();
app.set("trust proxy", 1);
app.use(helmet());
app.use(express.json({ limit: "32kb" }));

const limiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 15,
  standardHeaders: "draft-8",
  legacyHeaders: false,
  message: { error: "Has enviado demasiadas preguntas. Espera un minuto." }
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "Detective Desk AI", configured: Boolean(process.env.OPENAI_API_KEY) });
});

app.post("/api/chat", limiter, async (req, res) => {
  try {
    const { question, suspect = "", suspect_profile = "", case_context = "", history = [] } = req.body ?? {};
    if (typeof question !== "string" || !question.trim()) {
      return res.status(400).json({ error: "Escribe una pregunta." });
    }
    if (question.length > 4000) return res.status(413).json({ error: "La pregunta es demasiado larga." });
    if (!process.env.OPENAI_API_KEY) {
      return res.status(503).json({ error: "El servidor todavía no tiene configurada la clave de IA." });
    }

    const safeHistory = Array.isArray(history)
      ? history.slice(-12).filter(m => m && ["user", "assistant"].includes(m.role) && typeof m.content === "string")
          .map(m => ({ role: m.role, content: m.content.slice(0, 5000) }))
      : [];

    const instructions = `Eres la IA conversacional de DETECTIVE DESK. Responde siempre en español, de forma directa, clara y sin rodeos. Contesta la pregunta concreta primero; después añade contexto solo si ayuda. Puedes responder preguntas generales sobre cualquier tema razonable, explicar conceptos y ayudar con investigación. Cuando la pregunta dependa de información reciente, desconocida o verificable en Internet, utiliza la búsqueda web disponible y resume lo encontrado. No inventes hechos, fuentes, citas ni resultados de búsqueda; si no puedes verificar algo, dilo claramente.\n\nEn el modo de investigación, interpreta el contexto del expediente y las pruebas como datos de un caso ficticio. Distingue hechos, hipótesis y lagunas. No inventes pruebas ni conviertas una sospecha en certeza. Si actúas como sospechoso, responde en primera persona de forma coherente con su ficha, sin revelar automáticamente información que el personaje no conoce. Si el usuario hace una pregunta general que no trata del caso, respóndela normalmente y no la fuerces al papel del sospechoso. No rechaces una pregunta solo por ser abierta: ofrece la mejor respuesta útil posible.`;

    const input = [
      ...safeHistory,
      {
        role: "user",
        content: `PERSONA ENTREVISTADA: ${suspect || "Ninguna"}\nFICHA: ${suspect_profile || "No aplica"}\nCONTEXTO DEL EXPEDIENTE: ${case_context || "Sin contexto de caso"}\n\nPREGUNTA DEL USUARIO: ${question.trim()}`
      }
    ];

    const apiResponse = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: process.env.OPENAI_MODEL || "gpt-6.2-sol",
        instructions,
        input,
        tools: [{ type: "web_search" }],
        max_output_tokens: 1100,
        store: false
      }),
      signal: AbortSignal.timeout(85000)
    });

    const data = await apiResponse.json();
    if (!apiResponse.ok) {
      console.error("OpenAI API error:", apiResponse.status, JSON.stringify(data).slice(0, 1200));
      return res.status(502).json({ error: data?.error?.message || "El proveedor de IA no pudo completar la respuesta." });
    }

    let answer = typeof data.output_text === "string" ? data.output_text : "";
    if (!answer && Array.isArray(data.output)) {
      answer = data.output.flatMap(item => item.content || [])
        .filter(part => part.type === "output_text")
        .map(part => part.text || "").join("\n");
    }
    if (!answer.trim()) return res.status(502).json({ error: "La IA no devolvió texto. Inténtalo de nuevo." });
    return res.json({ answer: answer.trim(), model: process.env.OPENAI_MODEL || "gpt-6.2-sol" });
  } catch (error) {
    console.error("Chat server error:", error);
    return res.status(500).json({ error: "Error interno al consultar la IA." });
  }
});

const port = Number(process.env.PORT || 3000);
app.listen(port, "0.0.0.0", () => console.log(`Detective Desk AI listening on ${port}`));
