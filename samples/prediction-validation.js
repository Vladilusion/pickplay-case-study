/**
 * Illustrative progressive enhancement for a prediction form.
 * Client-side checks improve feedback only; the server must repeat validation,
 * authorization, match-state, and closing-time checks transactionally.
 */
export function parseScore(rawValue, { minimum = 0, maximum = 99 } = {}) {
  const normalized = String(rawValue).trim();

  if (!/^\d+$/.test(normalized)) {
    return { valid: false, error: "Enter a whole, non-negative score." };
  }

  const value = Number(normalized);
  if (!Number.isSafeInteger(value) || value < minimum || value > maximum) {
    return { valid: false, error: `Enter a score from ${minimum} to ${maximum}.` };
  }

  return { valid: true, value };
}

export function validatePrediction({ homeScore, awayScore, closesAt }, now = new Date()) {
  const home = parseScore(homeScore);
  const away = parseScore(awayScore);
  const closingInstant = new Date(closesAt);
  const errors = {};

  if (!home.valid) errors.homeScore = home.error;
  if (!away.valid) errors.awayScore = away.error;
  if (Number.isNaN(closingInstant.getTime())) errors.closesAt = "Closing time is unavailable.";
  else if (now.getTime() >= closingInstant.getTime()) errors.form = "This match is closed.";

  if (Object.keys(errors).length > 0) return { valid: false, errors };

  return {
    valid: true,
    value: { homeScore: home.value, awayScore: away.value },
  };
}

export function attachPredictionValidation(form, clock = () => new Date()) {
  form.addEventListener("submit", (event) => {
    const result = validatePrediction(
      {
        homeScore: form.elements.homeScore.value,
        awayScore: form.elements.awayScore.value,
        closesAt: form.dataset.closesAt,
      },
      clock(),
    );

    if (!result.valid) {
      event.preventDefault();
      form.dispatchEvent(new CustomEvent("prediction:invalid", { detail: result.errors }));
    }
  });
}
