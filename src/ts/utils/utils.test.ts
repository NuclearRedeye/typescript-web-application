import { createTextElement } from './utils';

describe('createTextElement', () => {
  it('creates an element', () => {
    const message = 'test content';
    const result = createTextElement(message);
    expect(result.innerHTML).toBe(message);
  });
});
