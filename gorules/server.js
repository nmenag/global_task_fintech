const express = require('express');
const { ZenEngine } = require('@gorules/zen-engine');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());

const engine = new ZenEngine();
const RULES_DIR = process.env.RULES_DIR || './rules';

// Helper to load content
const getRuleContent = (ruleName) => {
  const filePath = path.join(RULES_DIR, `${ruleName}.json`);
  if (fs.existsSync(filePath)) {
    return fs.readFileSync(filePath, 'utf8');
  }
  return null;
};

app.post('/evaluate/:ruleName', async (req, res) => {
  const { ruleName } = req.params;
  const context = req.body;

  try {
    const content = getRuleContent(ruleName);
    if (!content) {
      return res.status(404).json({ error: `Rule '${ruleName}' not found in ${RULES_DIR}` });
    }

    console.log(`Evaluating rule: ${ruleName}`);

    // Create a decision from the rule content and evaluate it
    const decision = engine.createDecision(JSON.parse(content));
    const result = await decision.evaluate(context);
    res.json(result);
  } catch (err) {
    console.error('Evaluation error:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', engine: 'zen-engine' });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Zen Engine Service listening on port ${PORT}`);
  console.log(`Rules directory: ${path.resolve(RULES_DIR)}`);
});
