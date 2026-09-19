# Zenn 向け記事シリーズ（推奨読み順）

Auth0 × Next.js を **1本完結で投稿できる単位**に再編したものです。

- **本編の `#`＝推奨読み順＝投稿順**（**01〜27 連番・欠番なし**）
- **投稿:** `記` = Zenn **記事** / `ス` = Zenn **スクラップ**（[`Scrap/`](./Scrap/)）
- **型:** `手` = ハンズオン / `概` = 概念 / `混` = 両方
- **競合:** `●` 一般競合が強い / `△` 競合多いが Docker×CLI で差別化 / `－` 少なめ・シリーズ固有
- CLI 共通手順は **01 に吸収**
- 未執筆候補は下表（番号は振らない。書いたら連番の末尾 or 挿入位置で振り直す）

## 本編（済・連番）

| # | 型 | 競合 | カテゴリ | 記事 | ねらい |
|---|----|------|----------|------|--------|
| 01 | 手 | △ | 導入 | [Next.js × Auth0 SDK v4 でログイン](./01-nextjs-auth0-v4-login.md) | 入口・流入（CLI 手順もここ） |
| 02 | 手 | △ | 導入 | [同一テナント SSO（App A/B）](./02-sso-app-a-b.md) | 複数アプリ SSO |
| 03 | 混 | △ | 導入 | [Silent Auth（prompt=none）](./03-silent-auth-prompt-none.md) | UI なし認可。正規は `auth0-lab.local`（localhost は consent_required になりやすい） |
| 04 | 手 | △ | セッション | [保護 API（/api/me）とセッション](./04-protected-api-session.md) | API 認証（ラボ `04-protected-api-session`） |
| 05 | 手 | △ | セッション | [Logout / セッション / Refresh](./05-logout-session-refresh.md) | セッション寿命 |
| 06 | 混 | △ | セッション | [Refresh Token Rotation 深掘り](./06-refresh-token-rotation.md) | RT 運用 |
| 07 | 手 | △ | セッション | [SSR / RSC と Access Token](./07-ssr-rsc-access-token.md) | App Router 注意点 |
| 08 | 手 | △ | API 認可 | [RBAC で Route Handler を守る](./08-rbac-route-handler.md) | API 認可 |
| 09 | 概 | － | API 認可 | [permission と scope の使い分け](./09-permission-vs-scope.md) | 認可の混同解消 |
| 10 | 手 | △ | API 認可 | [Bearer + JWKS で API を守る](./10-bearer-jwks-api.md) | API 保護（署名検証） |
| 11 | 手 | △ | API 認可 | [CORS + SPA から Bearer](./11-cors-spa-bearer.md) | 別オリジン呼び出し |
| 12 | 手 | △ | マシン認証 | [M2M（Client Credentials）](./12-m2m-client-credentials.md) | マシン認証 |
| 13 | 手 | △ | マシン認証 | [Management API × M2M](./13-management-api-m2m.md) | 運用自動化 |
| 14 | 手 | △ | 入り口 | [Passwordless / Social](./14-passwordless-social.md) | 複数の入り口 |
| 15 | 混 | － | 入り口 | [Account Linking](./15-account-linking.md) | ユーザー分裂 |
| 16 | 混 | － | 入り口 | [Custom DB → API → PostgreSQL](./16-custom-db-postgres.md) | レガシー移行 |
| 17 | 混 | － | 属性・Action | [Metadata + Post-Login Action](./17-metadata-post-login-action.md) | 属性付与 |
| 18 | 概 | － | 属性・Action | [SDK v4 と custom claims](./18-sdk-v4-custom-claims.md) | つまずき解消 |
| 19 | 混 | － | 属性・Action | [Actions ログイン分岐](./19-actions-login-branching.md) | deny / MFA |
| 20 | 混 | － | B2B | [Organizations + claims](./20-organizations-claims.md) | B2B |
| 21 | 手 | △ | B2B | [Organization 招待](./21-org-invitation.md) | B2B メンバー追加 |
| 22 | 手 | △ | B2B | [Organization + RBAC で API を守る](./22-org-rbac-api.md) | Org×権限 |
| 23 | 混 | △ | セキュリティ | [MFA + Attack Protection](./23-mfa-attack-protection.md) | アカウント保護 |
| 24 | 手 | △ | セキュリティ | [Passkeys 有効化](./24-passkeys.md) | パスワードレス進化 |
| 25 | 概 | － | 運用・判断 | [無料プランの境界](./25-free-plan-boundaries.md) | 見積・判断 |
| 26 | 混 | － | 運用・判断 | [ログの見方](./26-auth0-logs.md) | 調査の型 |
| 27 | 混 | － | 見た目 | [Universal Login Branding Tip](./27-ul-branding-tip.md) | ログイン画面の見た目 |

**本編集計:** 済 **27**（`#`＝投稿順・欠番なし）  
**差別化の柱:** `01-...` / `02-...` ラボ + Auth0 CLI。競合 `△` は手順固定で勝つ想定。

## 未執筆候補（番号未割当）

書いたら本編の適切な位置に挿入し、**全体を連番で振り直す**。

| 挿入目安 | 型 | 競合 | タイトル | ねらい |
|----------|----|------|----------|--------|
| 01 のあと | 混 | － | Allowed Callback / Logout / Web Origins の設計 | 設定ミスの定番 |
| 01〜02 付近 | 手 | － | Connection × Application の有効化 | 「このアプリだけ Social」 |
| 02 / 05 付近 | 混 | － | ローカル Logout vs Federated Logout | SSO 切れ方の本編化 |
| 13 のあと | 手 | － | ユーザー検索・一覧（Dashboard / CLI） | 運用の入口 |
| 同上 | 手 | － | ユーザーブロック / パスワードリセット運用 | Mgmt API or Dashboard |
| 17 付近 | 混 | － | Email Verification（未確認メールを弾く） | Action or Dashboard |
| 14 の前後 | 手 | ● | Social を 1 本深掘り（Google など） | Connection 有効化 |
| 14 の前後 | 手 | ● | Passwordless（Email）だけ切出し | Passwordless 単体 |
| 23 のまえ | 混 | － | Attack Protection だけ（Bot / Brute-force） | Free で触れる範囲を明示 |

## 優先度低（スクラップ）

一覧・スタブは **[`Scrap/README.md`](./Scrap/README.md)**。  
Scrap 内の番号（29〜69 など）は **本編 01〜27 とは別系統**（フォルダで分離）。

- 投稿しなくてもよい。必要なら Zenn **スクラップ** で出す  
- よく使う補足例: [30 `.env`](./Scrap/30-env-checklist.md) / [31 Domain](./Scrap/31-auth0-domain-no-https.md) / [66 エラー辞典](./Scrap/66-common-errors.md)

## 帯分け（本編）

| 帯 | # | 売り |
|----|---|------|
| A 導入＋API | 01〜13 | ログイン（CLI 含む）・SSO・セッション・RBAC・Bearer・M2M |
| B 入り口・属性 | 14〜19 | Social・Linking・Custom DB・Action |
| C B2B | 20〜22 | Org / 招待 / Org×RBAC |
| D 守り | 23〜24 | MFA / Passkeys |
| E 判断・見た目 | 25〜27 | プラン / Logs / Branding |

## 執筆・投稿の目安

未執筆候補の優先:

1. Callback / Logout / Web Origins（01 のあと）  
2. Federated Logout（02 / 05 付近）  
3. Email Verification  
4. Attack Protection（Free 範囲）  
5. Connection × Application  

## 意図的に zenn から外したもの

| 外したもの | 理由 | ラボ |
|------------|------|------|
| 旧 CLI 専用記事 | **01 に吸収** | — |
| CLI テナント一括再現 | リポ固有・運用メモ寄り | （未移植） |
| Custom Domain | 実 DNS 無しだと弱い | [old/15](../old/15-custom-domain.md) |
| Enterprise 概要のみ | 実 IdP 無しだと概念止まり | [old/17](../old/17-enterprise-connection.md) |
| 総復習チェックリスト | 連載向け | [old/12](../old/12-lab-checklist.md) |
| Self-Service SSO / SCIM | Free でも可だが環境依存が強い | （未着手） |

## 投稿時の注意

- Pricing・プラン表記は公式を確認してから公開  
- 相互リンクは公開後に Zenn URL へ差し替え  
- **本編 `#` 順に投稿**する（欠番を作らない）  
- スクラップは [`Scrap/`](./Scrap/)（任意）。長くなったら本編へ昇格
