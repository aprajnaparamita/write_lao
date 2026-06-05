/**
 * Deterministic tester ID — same device info always yields the same ID,
 * so testers can return on any device/browser and see their submissions.
 */

export async function generateTesterId(
  deviceModel: string,
  osVersion: string,
  appVersion: string,
  testerName: string,
): Promise<string> {
  const input = [deviceModel, osVersion, appVersion, testerName]
    .map(s => (s || '').trim().toLowerCase())
    .join('|');
  const hash = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(input),
  );
  // 16-char hex — compact but collision-resistant enough for this use case
  return Array.from(new Uint8Array(hash))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('')
    .substring(0, 16);
}
