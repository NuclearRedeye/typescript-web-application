import { createTextElement } from './utils';

describe('createTextElement', function() {
  it('creates an element', function() {
    const message = 'test content';
    const result = createTextElement(message);
    expect(result.innerHTML).toBe(message);
  });
});
