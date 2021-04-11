export function createTextElement(message: string): HTMLParagraphElement {
  const element = document.createElement('p');
  element.innerHTML = message;
  return element;
}
