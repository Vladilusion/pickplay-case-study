<?php

declare(strict_types=1);

/**
 * Illustrative PHP 8.2+ scoring model. Points are stored in half-point
 * units to represent a 1.5 multiplier without binary floating-point error.
 */

final readonly class Score
{
    public function __construct(public int $home, public int $away)
    {
        if ($home < 0 || $away < 0) {
            throw new InvalidArgumentException('Scores must be non-negative.');
        }
    }

    public function difference(): int
    {
        return $this->home - $this->away;
    }

    public function outcome(): int
    {
        return $this->difference() <=> 0;
    }
}

final readonly class ScoringRules
{
    public function __construct(
        public int $exactUnits = 10,
        public int $goalDifferenceUnits = 6,
        public int $winnerUnits = 4,
        public int $drawUnits = 4,
        public int $wildcardNumerator = 3,
        public int $wildcardDenominator = 2,
    ) {
        foreach ([$exactUnits, $goalDifferenceUnits, $winnerUnits, $drawUnits] as $units) {
            if ($units < 0) {
                throw new InvalidArgumentException('Point units must be non-negative.');
            }
        }

        if ($wildcardNumerator < 0 || $wildcardDenominator <= 0) {
            throw new InvalidArgumentException('The wildcard ratio must be valid.');
        }
    }
}

final readonly class ScoreAward
{
    public function __construct(public int $units, public string $reason)
    {
    }

    public function displayPoints(): string
    {
        return number_format($this->units / 2, 1, '.', '');
    }
}

final class ScoringEngine
{
    public function __construct(private readonly ScoringRules $rules)
    {
    }

    public function calculate(Score $prediction, Score $result, bool $applyWildcard = false): ScoreAward
    {
        [$units, $reason] = $this->classify($prediction, $result);

        if ($applyWildcard) {
            $scaledUnits = $units * $this->rules->wildcardNumerator;
            if ($scaledUnits % $this->rules->wildcardDenominator !== 0) {
                throw new LogicException('Configured multiplier cannot be represented in half-point units.');
            }
            $units = intdiv($scaledUnits, $this->rules->wildcardDenominator);
            $reason .= '_wildcard';
        }

        return new ScoreAward($units, $reason);
    }

    /** @return array{int, string} */
    private function classify(Score $prediction, Score $result): array
    {
        if ($prediction->home === $result->home && $prediction->away === $result->away) {
            return [$this->rules->exactUnits, 'exact_score'];
        }

        if ($result->outcome() !== 0 && $prediction->difference() === $result->difference()) {
            return [$this->rules->goalDifferenceUnits, 'goal_difference'];
        }

        if ($prediction->outcome() === 0 && $result->outcome() === 0) {
            return [$this->rules->drawUnits, 'correct_draw'];
        }

        if ($prediction->outcome() === $result->outcome()) {
            return [$this->rules->winnerUnits, 'correct_winner'];
        }

        return [0, 'no_match'];
    }
}
