# md-ebook — 마크다운을 책처럼 (스킬)

`.md` 한 편을 **오프라인 단일 HTML 책 리더**로 변환하는 글로벌 스킬.
사용법·기능·마크다운 규약은 [SKILL.md](./SKILL.md) 참고. 여기는 폴더 안내만.

## 파일

| 파일 | 역할 |
|---|---|
| `SKILL.md` | 스킬 진입점 — 변환법·리더 기능·입력 규약 |
| `reader.html` | 책 리더 템플릿 겸 데모. md 블록만 갈아끼우면 됨 |
| `build.py` | `python build.py <문서.md> [출력.html]` — 스크립트만으로 변환 (AI 개입 0) |
| `test.md` | 변환 검증용 예시 입력 |

## 변환이 동작하는 이유

`reader.html` 이 런타임 마크다운 파서를 내장하고 있어, 콘텐츠는 파일 안
`<script type="text/markdown" id="book-md">` 블록에 **원본 .md 그대로** 들어간다.
그래서 변환은 "그 블록만 교체"하는 문자열 치환 하나(`build.py`)면 끝 — LLM 이 HTML 을 생성하지 않는다.

## 출처

리더 디자인은 Claude Design(claude.ai/design) 핸드오프 번들의 `책 리더.html` 을 채택.
외부 라이브러리·CDN 0, 자체 파서 내장 → 폰·오프라인에서 파일 하나로 열린다.

## 등록

`~/.claude/skills/md-ebook` · `~/.agents/skills/md-ebook` junction 으로 연결됨 (Claude·codex·gemini 공통).
