export default {
  collectCoverage: true,
  coverageDirectory: "./dist/coverage",
  coverageThreshold: {
    global: {
      branches: 100,
      functions: 100,
      lines: 100,
      statements: 0
    }
  },
  transform: {
    "^.+\\.(t|j)sx?$": "ts-jest"
  },
  testRegex: "/src/.*\\.(test|spec)?\\.(ts|tsx)$",
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"]
}